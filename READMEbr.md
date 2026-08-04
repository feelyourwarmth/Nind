# Nind — Niri + Noctalia Dots

<small><sub>_Imagem meramente ilustrativa. A aparência da configuração pode mudar com futuras atualizações._</sub></small>
<p align="center">
  <img src="demo.png" alt="Preview">
</p>

<p align="center">
  Dotfiles para <b>Arch Linux + niri (Wayland)</b>, com instalação totalmente automatizada.
</p>

---

## Sobre

O **Nind** é minha configuração pessoal para **Arch Linux** utilizando **Wayland**, o compositor em tiling **niri** e o shell **Noctalia v5**.

Além dos dotfiles, o projeto inclui um instalador (`install.sh`) capaz de transformar uma instalação mínima do Arch em um desktop completamente funcional, instalando pacotes, drivers, serviços e copiando todas as configurações automaticamente.

<small><sub><b>Observação:</b><br>
<i>O script de instalação foi desenvolvido e testado por mim em instalações limpas do Arch Linux (DE Minimal).</i><br>
<i>Além disso, ele foi revisado para minimizar possíveis problemas durante a instalação dos dotfiles.</i><br>
<i>Ainda assim, caso prefira, você pode ignorar o script e instalar ou copiar os dotfiles manualmente no seu sistema.</i></sub></small>

## Recursos

- niri configurado com integração ao Noctalia
- Noctalia v5 (shell, theming e wallpapers inclusos)
- Vicinae (App Launcher)
- Kitty
- Fish
- Neovim (LazyVim)
- Starship
- Fastfetch
- Zen Browser
- Cava
- Suporte ao `yay`
- Instalação automática de drivers (NVIDIA, AMD ou Intel)
- Instalação automática dos dotfiles
- Backup automático das configurações antigas antes da instalação

---

## O que o instalador faz

O `install.sh` roda em 11 etapas:

1. Habilita o repositório `multilib` (necessário para libs 32-bit, ex: Steam).
2. Atualiza o sistema (`pacman -Syu`).
3. Instala o `yay` (AUR helper), se ainda não existir.
4. Instala dependências base: niri, xwayland-satellite, terminal (Kitty), shell (Fish), fontes, portais XDG, Zen Browser, Noctalia (`noctalia-git`), matugen, Cava, entre outros.
5. Pergunta qual GPU você tem (NVIDIA / AMD / Intel) e instala os drivers correspondentes. Para NVIDIA, pergunta também a geração da placa (open/atual, legacy 580xx, ou legacy antigo 390xx/340xx) e avisa sobre o suporte limitado dos drivers legacy no Wayland.
6. Faz backup do `~/.config` e `~/.local` atuais antes de sobrescrever qualquer coisa.
7. Copia os dotfiles deste repositório para `~/.config` e `~/.local`.
8. Instala e configura o SDDM com um tema.
9. Ativa os serviços necessários (SDDM, NetworkManager, PipeWire).
10. Etapa opcional: permite escolher pacotes extras para instalar.
11. Instala Vicinae.
12. Finaliza: cache de fontes, shell padrão (Fish), tema de ícones, e reinicia o sistema.

---

## Requisitos

- Arch Linux instalado de forma **minimal**, sem ambiente gráfico prévio.
  Caso queira instalar os dots em uma máquina que já tenha coisas instaladas, é recomendado que instale os dots manualmente, seguindo a documentação do niri e do Noctalia v5.
- Usuário normal com acesso a `sudo` (o script não deve ser rodado como root).
- Conexão com a internet.

---

## Instalação

Após instalar o **Arch Linux**, execute:

```bash
git clone https://github.com/feelyourwarmth/Nind.git
cd Nind

chmod +x install.sh
./install.sh
```

Não rode com `sudo`. O próprio script solicita permissões de administrador quando necessário.

Quando terminar, o sistema reinicia automaticamente e você poderá entrar na sessão do niri.

---

## Estrutura

```text
.
├── install.sh
├── .config
│   ├── niri/            # config do compositor (niri + integração com Noctalia)
│   ├── fish/             # shell
│   ├── kitty/            # terminal
│   ├── nvim/             # editor (LazyVim)
│   ├── gtk-3.0/ gtk-4.0/
│   ├── qt5ct/ qt6ct/
│   ├── fastfetch/
│   ├── starship.toml
│   └── wallpapers/
└── .local
    └── state/noctalia/   # estado e configurações do Noctalia
```

Os atalhos e configurações do niri ficam definidos em:

```text
~/.config/niri/config.kdl
```

---

## Avisos

- O script sobrescreve `~/.config` e `~/.local`, mas cria um backup automático (`~/dots-backup-<data>`) antes de qualquer alteração.
- Drivers NVIDIA legacy (390xx/340xx) têm suporte fraco ou inexistente a Wayland — o niri pode não funcionar corretamente nessas placas.
- Ao final da instalação, o sistema reinicia automaticamente após 5 segundos (dá para cancelar com `CTRL + C`).
- As configurações são atualizadas conforme vou modificando meu ambiente de trabalho.

---

Feito por mim para uso diário, mas sinta-se à vontade para usar, modificar e adaptar às suas necessidades.
