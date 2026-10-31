#!/usr/bin/env python3
"""Descarga la Ley Federal del Trabajo de la Cámara de Diputados y la convierte
en assets/lft/lft.json para la app.

Uso:  python3 tools/lft_to_json.py [--pdf archivo.pdf] [--out assets/lft/lft.json]
Requiere: pdftotext (poppler-utils).
"""
import argparse
import datetime
import json
import re
import subprocess
import sys
import unicodedata
import urllib.request

SOURCE = "https://www.diputados.gob.mx/LeyesBiblio/pdf/LFT.pdf"

HEADER_RES = [
    re.compile(r"^LEY FEDERAL DEL TRABAJO$"),
    re.compile(r"^C[ÁA]MARA DE DIPUTADOS DEL H\. CONGRESO DE LA UNI[ÓO]N$", re.I),
    re.compile(r"^Secretar[íi]a General$", re.I),
    re.compile(r"^Secretar[íi]a de Servicios Parlamentarios$", re.I),
    re.compile(r"^[ÚU]ltima [Rr]eforma (publicada )?DOF \d{2}-\d{2}-\d{4}$"),
    re.compile(r"^\d+ de \d+$"),
]

SUFIJOS = r"(?:Bis|Ter|Qu[aá]ter|Quintus|Quinquies|Sexies|Septies|Octies|Nonies|Decies)"
ART_RE = re.compile(
    r"^Art[íi]culo\s+(\d+)\s*([oº°])?\.?\s*(?:[-–]\s*([A-Z])(?![a-záéíóúñ]))?\s*"
    r"(" + SUFIJOS + r"(?:\s*\d+)?)?\s*(?:\.\s*[-–—]+|[-–—]+|\.)\s*"
    r"(?=[A-ZÁÉÍÓÚÑ(¿\"“«]|$)(.*)$"
)
TITULO_RE = re.compile(r"^T[ÍI]TULO\s+[A-ZÁÉÍÓÚ]+(?:\s+[A-ZÁÉÍÓÚ]+)?\s*$")
CAP_RE = re.compile(r"^CAP[ÍI]TULO\s+[IVXLC]+(?:\s+(?:BIS|TER|QU[AÁ]TER))?\s*$", re.I)
NOTE_RE = re.compile(
    r"^(?:(?:Art[íi]culo|P[áa]rrafo|Fracci[óo]n|Inciso|Cap[íi]tulo|T[íi]tulo|Secci[óo]n|Denominaci[óo]n|Fe de erratas)[^.]{0,120}"
    r"(?:reformad|adicionad|derogad|recorrid|DOF)).*DOF \d{2}-\d{2}-\d{4}.*$",
    re.I,
)


def norm(s: str) -> str:
    s = unicodedata.normalize("NFD", s.lower())
    return "".join(c for c in s if unicodedata.category(c) != "Mn")


def download(dest: str) -> None:
    req = urllib.request.Request(SOURCE, headers={"User-Agent": "Mozilla/5.0 (CalculadoraLaboral build)"})
    with urllib.request.urlopen(req, timeout=120) as r, open(dest, "wb") as f:
        f.write(r.read())


def pdf_to_lines(pdf: str):
    txt = subprocess.run(["pdftotext", "-enc", "UTF-8", pdf, "-"], check=True,
                         capture_output=True, text=True).stdout
    txt = txt.replace("\f", "\n")
    return [l.rstrip() for l in txt.split("\n")]


def parse(lines):
    version = None
    for l in lines[:200]:
        m = re.search(r"[ÚU]ltima [Rr]eforma (?:publicada )?DOF (\d{2}-\d{2}-\d{4})", l)
        if m:
            version = m.group(1)
            break

    # Quitar encabezados/pies de página
    clean = [l.strip() for l in lines if not any(r.match(l.strip()) for r in HEADER_RES)]

    # Inicio: primer "TÍTULO PRIMERO"; fin: primer "TRANSITORIOS"
    start = next(i for i, l in enumerate(clean) if re.match(r"^T[ÍI]TULO PRIMERO\s*$", l))
    end = next((i for i, l in enumerate(clean) if i > start and re.match(r"^(ARTÍCULOS )?TRANSITORIOS?\s*$", l, re.I)), len(clean))
    body = clean[start:end]

    articles = []
    titulo = capitulo = ""
    pending_heading = None  # ("t"|"c", texto)
    cur = None
    buf = []

    def flush_para():
        nonlocal buf
        if cur is not None and buf:
            text = " ".join(buf)
            text = re.sub(r"(\w)- (\w)", r"\1\2", text)  # guiones de corte de línea
            text = re.sub(r"\s+", " ", text).strip()
            if text:
                (cur["notas"] if NOTE_RE.match(text) and len(text) < 260 else cur["p"]).append(text)
        buf = []

    def close_article():
        flush_para()

    i = 0
    while i < len(body):
        l = body[i]
        if TITULO_RE.match(l) or CAP_RE.match(l):
            close_article()
            kind = "t" if TITULO_RE.match(l) else "c"
            # el nombre suele ir en la(s) siguiente(s) línea(s) no vacías
            name_parts = []
            j = i + 1
            while j < len(body) and len(name_parts) < 3:
                b = body[j]
                if not b and name_parts:
                    break
                if ART_RE.match(b) or TITULO_RE.match(b) or CAP_RE.match(b):
                    break
                if b and not re.search(r"DOF \d{2}-\d{2}-\d{4}", b):
                    name_parts.append(b)
                j += 1
            label = l.title().replace("Titulo", "Título").replace("Capitulo", "Capítulo")
            for a_, b_ in [("Septimo", "Séptimo"), ("Decimo", "Décimo"), ("Dieciseis", "Dieciséis"),
                           ("Quater", "Quáter")]:
                label = label.replace(a_, b_)
            label = re.sub(r"\b(Ii|Iii|Iv|Vi|Vii|Viii|Ix|Xi|Xii|Xiii|Xiv|Xv|Xvi|Xvii|Xviii|Xix|Xx|Xxi|Xxii|Xxiii|Bis)\b",
                           lambda m: m.group(1).upper(), label)
            full = (label + (" · " + " ".join(name_parts) if name_parts else "")).strip()
            if kind == "t":
                titulo, capitulo = full, ""
            else:
                capitulo = full
            cur = None
            i = j
            continue

        m = ART_RE.match(l)
        if m:
            close_article()
            num, ordi, letra, suf, rest = m.groups()
            letra = (letra or "").strip()
            suf = re.sub(r"\s+", " ", (suf or "").strip())
            ident = num + ("o" if ordi else "") + ("-" + letra if letra else "") + (" " + suf if suf else "")
            key = num + ("-" + letra if letra else "") + (" " + suf.lower().replace("á", "a") if suf else "")
            cur = {"id": ident, "k": key, "n": int(num), "t": titulo, "c": capitulo, "p": [], "notas": []}
            articles.append(cur)
            buf = [rest] if rest else []
            i += 1
            continue

        if cur is not None and NOTE_RE.match(l):
            flush_para()
            cur["notas"].append(l)
            i += 1
            continue

        if cur is not None:
            if not l:
                flush_para()
            elif re.match(r"^([IVXLC]+\.|[a-z]\)|\d+\.)\s", l) and buf:
                # nueva fracción / inciso
                flush_para()
                buf = [l]
            else:
                buf.append(l)
        i += 1
    close_article()
    return version, articles


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pdf")
    ap.add_argument("--out", default="assets/lft/lft.json")
    a = ap.parse_args()
    pdf = a.pdf
    if not pdf:
        pdf = "/tmp/LFT.pdf"
        download(pdf)
    version, arts = parse(pdf_to_lines(pdf))

    # Validaciones: si algo no cuadra, NO se reemplaza el archivo anterior.
    keys = {x["k"] for x in arts}
    must = ["1", "48", "50", "76", "80", "87", "162", "486", "1010"]
    missing = [k for k in must if k not in keys]
    problems = []
    if len(arts) < 900:
        problems.append(f"solo {len(arts)} artículos")
    if missing:
        problems.append("faltan artículos " + ", ".join(missing))
    if not version:
        problems.append("no se encontró la fecha de última reforma")
    from collections import Counter
    dups = [k for k, c in Counter(x["k"] for x in arts).items() if c > 1]
    if len(dups) > 5:
        problems.append("claves repetidas: " + ", ".join(dups[:10]))
    print("Repetidos:", dups[:20])
    empty = [x["id"] for x in arts if not x["p"]]
    print(f"Versión DOF {version} · {len(arts)} artículos · {len(empty)} vacíos")
    a87 = next((x for x in arts if x["k"] == "87"), None)
    if a87:
        print("Art. 87:", a87["t"], "|", a87["c"], "|", a87["p"][:2])
    if problems:
        print("ERROR: " + "; ".join(problems))
        sys.exit(2)

    data = {
        "ley": "Ley Federal del Trabajo",
        "version": version,
        "fuente": SOURCE,
        "descargado": datetime.date.today().isoformat(),
        "articulos": arts,
    }
    with open(a.out, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
    print("OK ->", a.out)


if __name__ == "__main__":
    main()
