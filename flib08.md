# 🖨️ FLIB08 - Biblioteca de Impressão e Relatórios para Harbour

A **`flib08`** é uma biblioteca modular escrita em **Harbour** projetada para gerenciar o subsistema de impressão, spooler e exportação de relatórios de sistemas corporativos. Ela atua como uma ponte flexível entre comandos de impressão legados (como `@ SAY` e impressoras matriciais/LPT) e formatos modernos de saída e compartilhamento (PDF, HTML, RTF, ODT, E-mail e impressoras térmicas Zebra).

---

## ✨ Principais Características

* **Menu de Saída Dinâmico (`CHECKIMP`):** Apresenta uma interface de seleção intuitiva para o operador escolher o destino do relatório (Vídeo, Portas LPT/COM, Windows WinPrn, TXT, HTML, RTF, PDF, ODT ou Zebra).
* **Suporte a Múltiplos Formatos:**
* **Texto / Spooler:** Tratamento de impressoras matriciais e portas locais (`LPT1` a `LPT3`, `COM1`, `COM2`).
* **Documentos Modernos:** Exportação nativa e integrada para **PDF** (HaruPDF), **RTF**, **HTML** e **ODT** (OpenDocument Text).


* **Etiquetas Térmicas (Zebra ZPL):** Integração com renderização e preview de etiquetas via API remota (`Labelary`).


* **Gerenciamento de Spooler e Erros:** Verificação prévia de status de impressoras físicas (`PRINTREADY`, `PRINTSTAT`) com opções customizadas de continuação em caso de falhas de hardware.


* **Disparo de E-mails Integrado (`FILETOEMAIL`):** Envio flexível de relatórios gerados via `HB_SendMail`, MAPI, Thunderbird ou integração avançada com provedores via `hbNFeEmail`.


* **Impressão Bruta (RAW):** Envio direto de arquivos PRN/TXT para o spooler do Windows (`WIN_PrintFileRaw` ou `Win32Prn`).



---

## 🚀 Fluxo de Utilização Padrão

O uso da biblioteca nos relatórios do sistema segue a estrutura clássica de abertura, processamento e fechamento de spool:

```harbour
PROCEDURE GerarRelatorio()
   // 1. Aciona o menu de escolha de destino (Passando 0 para exibir a tela de seleção)
   IF ! CHECKIMP( 0, .T., .F. )
      RETURN  // Usuário cancelou
   ENDIF

   // 2. Executa a impressão usando os comandos normais do Harbour
   @ PRow(), 0 SAY "Relatório de Vendas"
   @ PRow() + 1, 0 SAY "----------------------------------------"
   @ PRow() + 1, 0 SAY "Item 01 - Produto A       R$ 100,00"
   
   // 3. Finaliza a impressão e dispara a conversão/envio automático (Vídeo, PDF, ODT, etc.)
   IMPEND()
RETURN

```

---

## 📖 Referência das Principais Funções

* **`CHECKIMP( nTIP, lIMPHP, lZEBRA )`**
Inicializa o subsistema de saída. Se `nTIP` for 0, exibe o menu interativo de seleção de dispositivos. Configura as variáveis globais de controle (`nTIPSPO`, `cARQSPO`).


* **`IMPEND( lAPAGA )`**
Finaliza o ciclo de impressão (`SET PRINT TO`), processa o arquivo temporário gerado e o converte/exibe de acordo com a opção escolhida pelo usuário no menu (abrindo o visualizador, enviando por e-mail ou mandando para a porta física).


* **`printtoodt( cARQ, cFileToSave )`**
Converte o arquivo de texto temporário de spool em um documento formatado **.odt** (OpenDocument Text) utilizando a classe nativa `DocumentODT`.


* **`filetopdf( cARQ, cFileToSave )`**
Converte o relatório impresso em um arquivo **PDF** estruturado utilizando a biblioteca HaruPDF.


* **`filezebrapdf( cARQSPO )`**
Processa arquivos de comandos **ZPL** (Zebra), enviando para a API de renderização e gerando o PDF correspondente para preview em tela.


* **`FILETOEMAIL( cARQ, cASSUNTO, cCORPOMSG )`**
Abre a interface de envio de e-mails para anexar e disparar o relatório gerado utilizando múltiplos provedores suportados.



---

## 📄 Licença

Módulo integrante do ecossistema de automação e utilitários em Harbour.