# Simulador de Micro-ondas 8086

**Nota:** Este projeto foi desenvolvido em 2016 como parte de um trabalho acadêmico universitário. Está sendo arquivado aqui para fins históricos e de portfólio.

## Descrição do Projeto

Este projeto simula o temporizador de um micro-ondas utilizando linguagem Assembly para a arquitetura Intel 8086.  
Foi desenvolvido utilizando o emulador **Emu8086**, que oferece uma interface gráfica simples para simular interações do usuário, como botões e LEDs.

O manual do usuário descreve como um usuário final operaria o micro-ondas simulado, enquanto o manual técnico explica a lógica interna e a estrutura do programa em Assembly.

## Estrutura

- `src/` - Contém o código-fonte Assembly (`Microondas8086.asm`).
- `manual-tecnico/` - Contém a documentação técnica explicando a implementação do projeto.
- `manual-usuario/` - Contém o manual do usuário, explicando como utilizar a simulação do micro-ondas.

## Como Compilar e Executar

1. Abra o projeto no **Emu8086**.
2. Monte e execute o programa dentro do emulador.

Alternativamente, é possível montar manualmente utilizando ferramentas como TASM + TLINK, caso prefira um ambiente DOS.

## Requisitos

- Emu8086 (recomendado) ou
- TASM / MASM + TLINK + emulador DOS (ex.: DOSBox)

---

Projeto arquivado com o conteúdo original preservado, para fins históricos.