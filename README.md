# 🌻 Controlador Digital para Rastreador Solar (Girassol)

![VHDL](https://img.shields.io/badge/Language-VHDL-blue)
![FPGA](https://img.shields.io/badge/Hardware-Altera__DE2-green)
![Status](https://img.shields.io/badge/Status-Completed-success)
![Institution](https://img.shields.io/badge/UFRN-DCA-red)

Projeto desenvolvido para a disciplina de **Sistemas Digitais (DCA 3301.0)** da Universidade Federal do Rio Grande do Norte (UFRN).

[cite_start]O objetivo é implementar um sistema de controle digital em nível RTL (Register Transfer Level) para um rastreador solar de eixo único, focado em eliminar a instabilidade mecânica causada por ruídos em sensores LDR[cite: 12, 393].

---

## 👥 Equipe
* **Célio Felipe Bezerra Santiago**
* **Gabriel André Amrim Soares**
* **To Ba Thanh Tung**
* **Lucas Henrique Alvez de Queiroz**

---

## ⚙️ O Problema e a Solução

Rastreadores solares analógicos sofrem com variações bruscas de luminosidade (nuvens, sombras), causando o acionamento errático do motor ("tremedeira"). [cite_start]Isso gera desperdício de energia e desgaste mecânico[cite: 13, 24, 394, 406].

**Nossa Solução:**
Desenvolvemos um controlador digital na FPGA que implementa:
1.  [cite_start]**Filtro Digital:** Um filtro de Média Móvel de 4 pontos para suavizar o sinal dos sensores[cite: 15, 397].
2.  [cite_start]**Histerese:** Uma "Zona Morta" (Threshold = 10) que impede o motor de ligar para pequenas variações de luz[cite: 16, 41, 398].

---

## 🛠️ Arquitetura do Sistema

O projeto foi dividido em dois blocos principais (RTL):

### 1. Caminho de Dados (Datapath)
Responsável pelo processamento matemático.
* **Pipeline:** Cadeia de registradores para armazenar as últimas 4 amostras.
* [cite_start]**Otimização de Hardware:** A divisão por 4 foi implementada via **Shift Right** (deslocamento de bits) de 2 posições, economizando recursos lógicos da FPGA em comparação com divisores convencionais[cite: 15, 112, 397, 500].

### 2. Bloco de Controle (FSM)
Uma Máquina de Estados Finitos que recebe os sinais comparados do Datapath e decide o acionamento do motor.
* [cite_start]**Estados:** `PARADO`, `GIRA_DIR`, `GIRA_ESQ` [cite: 36-38, 418-420].
* **Lógica:** O motor só é acionado se `|Sensor_L - Sensor_R| > [cite_start]10`[cite: 41, 398].

---

## 💻 Tecnologias Utilizadas

* [cite_start]**Linguagem:** VHDL[cite: 17, 399].
* [cite_start]**Software:** Quartus II Web Edition & ModelSim[cite: 17, 206, 399, 594].
* [cite_start]**Hardware Alvo:** Kit Altera DE2 (FPGA Cyclone II EP2C35F672)[cite: 17, 188, 399, 576].

---

## 📊 Resultados e Simulação

O sistema foi validado via simulação (Waveform) comprovando a robustez do filtro de histerese.

*(Recomenda-se adicionar a imagem do Waveform aqui: `img/waveform.png`)*

> [cite_start]**Teste de Histerese:** Ao simular uma diferença de 5 unidades (Sensor L=105, Sensor R=100), o motor permaneceu desligado, provando que o sistema ignora ruídos abaixo do limiar de 10[cite: 185, 186, 573, 574].

---

## 🚀 Como Executar

### Pré-requisitos
* Quartus II (versão compatível com Cyclone II, ex: 13.0sp1).
* ModelSim Altera.

### Passos
1.  Clone o repositório:
    ```bash
    git clone [https://github.com/DIGAOZX/sistemas_digitais_girassol.git](https://github.com/DIGAOZX/sistemas_digitais_girassol.git)
    ```
2.  Abra o arquivo `.qpf` (Quartus Project File) no Quartus.
3.  Compile o projeto.
4.  Para simular, utilize o arquivo de testbench fornecido na pasta `simulation`.

---

## 📂 Estrutura de Arquivos
