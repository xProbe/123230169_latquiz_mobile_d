import sys
from pypdf import PdfReader

def extract_pdf():
    try:
        reader = PdfReader('e:/kuliah/praktikum_mobile/lat_quiz/Latihan_Kuis_Mobile_IF_D.pdf')
        with open('e:/kuliah/praktikum_mobile/lat_quiz/extracted_pdf.txt', 'w', encoding='utf-8') as f:
            for i, page in enumerate(reader.pages):
                f.write(f"--- Page {i+1} ---\n")
                f.write(page.extract_text() + "\n")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    extract_pdf()
