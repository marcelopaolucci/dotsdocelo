#!/bin/bash
#    ____         __       ____               __     __
#   /  _/__  ___ / /____ _/ / / __ _____  ___/ /__ _/ /____ ___
#  _/ // _ \(_-</ __/ _ `/ / / / // / _ \/ _  / _ `/ __/ -_|_-<
# /___/_//_/___/\__/\_,_/_/_/  \_,_/ .__/\_,_/\_,_/\__/\__/___/
#                                 /_/
#

sleep 1
clear
install_platform="$(cat ~/.config/ml4w/settings/platform.sh)"
figlet -f smslant "Updates"
echo

# ------------------------------------------------------
# Confirm Start
# ------------------------------------------------------

if gum confirm "DESEJA INICIAR A ATUALIZAÇÃO AGORA?"; then
    echo
    echo ":: Atualização iniciada."
elif [ $? -eq 130 ]; then
    exit 130
else
    echo
    echo ":: Atualização cancelada."
    exit
fi

_isInstalled() {
    package="$1"
    case $install_platform in
        arch)
            check="$($aur_helper -Qs --color always "${package}" | grep "local" | grep "${package} ")"
            ;;
        fedora)
            check="$(dnf repoquery --quiet --installed ""${package}*"")"
            ;;
        *) ;;
    esac

    if [ -n "${check}" ]; then
        echo 0 #'0' significa 'verdadeiro' no Bash
        return #verdadeiro
    fi
    echo 1 #'1' significa 'falso' no Bash
    return #falso
}

# Verifica se a plataforma é suportada
case $install_platform in
    arch)
        aur_helper="$(cat ~/.config/ml4w/settings/aur.sh)"

        if [[ $(_isInstalled "timeshift") == "0" ]]; then
            echo
            if gum confirm "DESEJA CRIAR UM SNAPSHOT?"; then
                echo
                c=$(gum input --placeholder "Digite um comentário para o snapshot...")
                sudo timeshift --create --comments "$c"
                sudo timeshift --list
                sudo grub-mkconfig -o /boot/grub/grub.cfg
                echo ":: PRONTO. Snapshot $c criado!"
                echo
            elif [ $? -eq 130 ]; then
                echo ":: Snapshot ignorado."
                exit 130
            else
                echo ":: Snapshot ignorado."
            fi
            echo
        fi

        $aur_helper

        if [[ $(_isInstalled "flatpak") == "0" ]]; then
            flatpak upgrade
        fi
        ;;
    fedora)
        sudo dnf upgrade
        if [[ $(_isInstalled "flatpak") == "0" ]]; then
            flatpak upgrade
        fi
        ;;
    *)
        echo ":: ERRO - Plataforma não suportada"
        echo "Pressione [ENTER] para fechar."
        read
        ;;
esac

notify-send "Atualização concluída"
echo
echo ":: Atualização concluída"
echo
echo

echo "Pressione [ENTER] para fechar."
read
