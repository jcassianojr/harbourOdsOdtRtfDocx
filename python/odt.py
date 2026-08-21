import zipfile
import xml.sax.saxutils

class ODTGenerator:
    def __init__(self, filename):
        self.filename = filename
        self.paragraphs = []

    def add_paragraph(self, text, style="P1"):
        """Adiciona um parágrafo ao documento."""
        escaped_text = xml.sax.saxutils.escape(text)
        self.paragraphs.append(f'<text:p text:style-name="{style}">{escaped_text}</text:p>')

    def add_heading(self, text, level=1):
        """Adiciona um título ao documento."""
        escaped_text = xml.sax.saxutils.escape(text)
        style = f"Heading_{level}"
        self.paragraphs.append(f'<text:h text:style-name="{style}" text:outline-level="{level}">{escaped_text}</text:h>')

    def save(self):
        """Gera e salva o arquivo .odt."""
        # 1. mimetype (deve ser o primeiro arquivo e não compactado)
        mimetype = "application/vnd.oasis.opendocument.text"

        # 2. META-INF/manifest.xml
        manifest = """<?xml version="1.0" encoding="UTF-8"?>
<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0" manifest:version="1.2">
 <manifest:file-entry manifest:full-path="/" manifest:media-type="application/vnd.oasis.opendocument.text"/>
 <manifest:file-entry manifest:full-path="content.xml" manifest:media-type="text/xml"/>
 <manifest:file-entry manifest:full-path="styles.xml" manifest:media-type="text/xml"/>
 <manifest:file-entry manifest:full-path="meta.xml" manifest:media-type="text/xml"/>
</manifest:manifest>"""

        # 3. meta.xml (metadados básicos)
        meta = """<?xml version="1.0" encoding="UTF-8"?>
<office:document-meta xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" office:version="1.2">
 <office:meta>
  <meta:generator>ODTGenerator Python</meta:generator>
 </office:meta>
</office:document-meta>"""

        # 4. styles.xml (estilos básicos)
        styles = """<?xml version="1.0" encoding="UTF-8"?>
<office:document-styles xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" office:version="1.2">
 <office:styles>
  <style:style style:name="Standard" style:family="paragraph"/>
  <style:style style:name="Heading_1" style:family="paragraph" style:parent-style-name="Standard">
   <style:text-properties fo:font-size="18pt" fo:font-weight="bold"/>
  </style:style>
  <style:style style:name="P1" style:family="paragraph" style:parent-style-name="Standard">
   <style:text-properties fo:font-size="12pt"/>
  </style:style>
 </office:styles>
</office:document-styles>"""

        # 5. content.xml (o conteúdo principal)
        body_content = "".join(self.paragraphs)
        content = f"""<?xml version="1.0" encoding="UTF-8"?>
<office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" office:version="1.2">
 <office:body>
  <office:text>
   {body_content}
  </office:text>
 </office:body>
</office:document-content>"""

        # Criação do arquivo ZIP (ODT)
        with zipfile.ZipFile(self.filename, 'w', zipfile.ZIP_DEFLATED) as zf:
            # O mimetype NUNCA deve ser compactado
            zf.writestr("mimetype", mimetype, compress_type=zipfile.ZIP_STORED)
            zf.writestr("META-INF/manifest.xml", manifest)
            zf.writestr("meta.xml", meta)
            zf.writestr("styles.xml", styles)
            zf.writestr("content.xml", content)

        print(f"Documento salvo com sucesso: {self.filename}")

# --- Exemplo de Uso ---
if __name__ == "__main__":
    doc = ODTGenerator("meu_documento.odt")
    doc.add_heading("Relatório Gerencial", level=1)
    doc.add_paragraph("Este é um parágrafo gerado automaticamente por um script em Python.")
    doc.add_paragraph("Arquivos ODT são leves, abrem no LibreOffice, Word e Google Docs.")
    doc.save()