#!/bin/bash
# Directorios
CIDdir="/etc/CAT-BOT"
DIRSCRIPT="/etc/cat/script"
DIR="/etc/http-shell"
IVAR="/etc/http-instas"
bar="\e[0;31m=====================================================\e[0m"
# Crear directorios si no existen
[[ ! -d ${CIDdir} ]] && mkdir ${CIDdir}
[[ ! -d ${DIRSCRIPT} ]] && mkdir -p ${DIRSCRIPT}

# Colores para mensajes
msg() {
    BRAN='\033[1;37m'
    VERMELHO='\e[31m'
    VERDE='\e[32m'
    AMARELO='\e[33m'
    AZUL='\e[34m'
    MAGENTA='\e[35m'
    MAG='\033[1;36m'
    NEGRITO='\e[1m'
    SEMCOR='\e[0m'
    case $1 in
    -ne) cor="${VERMELHO}${NEGRITO}" && echo -ne "${cor}${2}${SEMCOR}" ;;
    -ama) cor="${AMARELO}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
    -verm) cor="${AMARELO}${NEGRITO}[!] ${VERMELHO}" && echo -e "${cor}${2}${SEMCOR}" ;;
    -azu) cor="${MAG}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
    -verd) cor="${VERDE}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
    -bra) cor="${BRAN}${NEGRITO}" && echo -ne "${cor}${2}${SEMCOR}" ;;
    -bar2) cor="\e[0;31m========================================\e[0m" && echo -e "${cor}${SEMCOR}" ;;
    -bar) cor="\e[1;31m——————————————————————————————————————————————————————" && echo -e "${cor}${SEMCOR}" ;;
    esac
}

# Obtener IP del servidor
meu_ip() {
    MIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
    MIP2=$(wget -qO- ipv4.icanhazip.com)
    [[ "$MIP" != "$MIP2" ]] && IP="$MIP2" || IP="$MIP"
    echo "$IP" >/usr/bin/vendor_code
}

# Configuración del sistema operativo
os_system() {
    system=$(cat -n /etc/issue | grep 1 | cut -d ' ' -f6,7,8 | sed 's/1//' | sed 's/      //')
    distro=$(echo "$system" | awk '{print $1}')
    case $distro in
    Debian) vercion=$(echo $system | awk '{print $3}' | cut -d '.' -f1) ;;
    Ubuntu) vercion=$(echo $system | awk '{print $2}' | cut -d '.' -f1,2) ;;
    esac
    link="https://raw.githubusercontent.com/rudi9999/ADMRufu/main/Repositorios/${vercion}.list"
    case $vercion in
    8 | 9 | 10 | 11 | 16.04 | 18.04 | 20.04 | 20.10 | 21.04 | 21.10 | 22.04) wget -O /etc/apt/sources.list ${link} &>/dev/null ;;
    esac
}

updatex() {
    clear
    msg -bar
    os_system
    msg -ama "$distro $version"
    msg -verm " INSTALACION DE PAQUETES "
    msg -bar
    msg -verd "    INSTALANDO ACTUALIZACIONES"
    apt update -y
    msg -verd "    PAQUETES ACTUALIZABLES"
    apt list --upgradable
    msg -verd "    ACTUALIZANDO PAQUETES"
    apt upgrade -y

    # Instalación de paquetes
    paquetes="jq bc curl netcat netcat-traditional net-tools apache2 zip unzip screen"
    for paquete in $paquetes; do
        msg -azu "       Verificando la instalación de $paquete ..."
        if dpkg -l | grep -q $paquete; then
            msg -verd "    El paquete $paquete ya está instalado."
        else
            msg -azu "       Instalando $paquete ..."
            if apt install $paquete -y &>/dev/null; then
                msg -verd "    Instalado correctamente"
            else
                msg -verm2 "    Falló la instalación de $paquete"
                msg -ama "Aplicando corrección para $paquete ..."
                dpkg --configure -a &>/dev/null
                if apt install $paquete -y &>/dev/null; then
                    msg -verd "    Instalado correctamente"
                else
                    msg -verm2 "    Falló la instalación de $paquete incluso después de la corrección"
                fi
            fi
        fi
    done

    # Configuraciones adicionales
    [[ ! -d ${IVAR} ]] && touch ${IVAR}
    #sed -i "s/Listen 80/Listen 81/g" /etc/apache2/ports.conf
    service apache2 restart >/dev/null 2>&1
    msg -bar
    msg -azu "Removiendo paquetes obsoletos"
    msg -bar
    apt autoremove -y &>/dev/null
    echo "00" >/root/.bash_history
    ufw allow 80/tcp &>/dev/null
    ufw allow 81/tcp &>/dev/null
    ufw allow 8888/tcp &>/dev/null
}


# Función para comprobar la dirección IP
check_ip() {
    MIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
    MIP2=$(wget -qO- ipv4.icanhazip.com)
    [[ "$MIP" != "$MIP2" ]] && IP="$MIP2" || IP="$MIP"
    echo "$IP" >/usr/bin/vendor_code
}

# Función para desinstalar el bot
unistall() {
    dir="/etc/CAT-BOT"
    rm -rf ${dir}
    echo "DETENIENDO EL PROCESO DEL BOT"
    sleep 2s
    killall BotGen.sh
    kill -9 $(ps aux | grep -v grep | grep -w "BotGen.sh" | grep dmS | awk '{print $2}') &>/dev/null
    kill $(ps aux | grep -v grep | grep -w "BotGen.sh") &>/dev/null

    killall http-server.sh
    rm -rf /bin/http-server.sh
    #rm -rf /bin/ShellBot.sh
    rm -rf /bin/vpsbot
    rm -rf /etc/cat/script
    rm -rf .bash_history
    sleep 3s
    clear
    echo "BOT DETENIDA"
}

# Función para mostrar un spinner
spiner() {
    local pid=$!
    local delay=1
    local spinner=('█■■■■■■' '■█■■■■■' '■■█■■■■' '■■■█■■■' '■■■■█■■' '■■■■■█■' '■■■■■■█-')
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        for i in "${spinner[@]}"; do
            tput civis
            echo -ne "\033[1;31m\r[\e[0m\e[1;32m~\e[0m\e[1;31m]\e[0m\e[1;96mInstalando....\e[31m[\033[32m$i\033[31m]     \033[0m       "
            sleep $delay
            printf "\b\b\b\b\b\b\b\b"
        done
    done
    printf "   \b\b\b\b\b"
    tput cnorm
    echo -e "\033[1;31m[\e[0m\e[1;33mInstalado\e[0m\e[1;31m]\e[0m"
}

# Función para descargar archivos y realizar instalaciones
descarga() {
    rm -rf .bash_history
    check_ip
    clear
    [[ ! -d ${IVAR} ]] && touch ${IVAR}
    wget -O /bin/http-server.sh https://www.dropbox.com/s/41ki8vioc3uezj5/http-server.sh &>/dev/null
    chmod +x /bin/http-server.sh
    msg -bar
    msg -verm " INSTALACION DE PAQUETES "
    msg -bar
    echo -e "\033[31m[\033[32m~\033[31m]\033[37m$instalando Update"
    apt-get update &>/dev/null &
    spiner
    echo -e "\033[31m[\033[32m~\033[31m]\033[37m$instalando Upgrade"
    apt-get upgrade -y &>/dev/null &
    spiner
    echo -e "\033[31m[\033[32m~\033[31m]\033[37m$instalando Unzip"
    apt-get install unzip -y &>/dev/null &
    spiner
    echo -e "\033[31m[\033[32m~\033[31m]\033[37m$instalando Zip"
    apt-get install zip -y &>/dev/null &
    spiner
    echo -e "\033[31m[\033[32m~\033[31m]\033[37m$instalando Lsof"
    apt-get install lsof >/dev/null 2>&1 &
    spiner
    echo -e "\033[31m[\033[32m~\033[31m]\033[37m$instalando Sudo"
    apt-get install sudo >/dev/null 2>&1 &
    spiner
    echo -e "\033[31m[\033[32m~\033[31m]\033[37m$instalando Screen"
    apt-get install screen -y >/dev/null 2>&1 &
    spiner
    echo -e "\033[31m[\033[32m~\033[31m]\033[37m$instalando Bc"
    apt-get install bc -y >/dev/null 2>&1 &
    spiner
    echo -e "\033[31m[\033[32m~\033[31m]\033[37m$instalando Netcat"
    apt-get install netcat -y >/dev/null 2>&1 &
    spiner
    echo -e "\033[31m[\033[32m~\033[31m]\033[37m$instalando Apache2"
    apt-get install apache2 -y &>/dev/null &
    spiner
    sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf
    service apache2 restart >/dev/null 2>&1 &
    # URLs de los repositorios
    repos="https://github.com/VPSCAT/KEYDARK/raw/main/VPSMX.zip"

    # Descargar archivos y descomprimir
    wget $repos &>/dev/null
    unzip VPSMX.zip &>/dev/null

    # Copiar archivos a los directorios correspondientes
    cp VPS-MX/* ${DIRSCRIPT}/

    # Asignar permisos de ejecución a los scripts
    chmod +x ${DIRSCRIPT}/*

    # Limpiar archivos temporales
    rm -rf VPSMX.zip
    rm -rf VPS-MX

    # Mensaje de descarga finalizada
    sleep 1s
    echo -e "$bar"
    msg -verm " DESCARGANDO ARCHIVOS BOT"
    echo -e "$bar"
    sleep 2s

    # Configurar archivos de instalación
    echo "menu message.txt usercodes C-SSR.sh squid.sh squid.sh dropbear.sh proxy.sh openvpn.sh ssl.sh python.py shadowsocks.sh Shadowsocks-libev.sh Shadowsocks-R.sh v2ray.sh slowdns.sh budp.sh sockspy.sh PDirect.py PPub.py PPriv.py POpen.py PGet.py ADMbot.sh apacheon.sh tcp.sh fai2ban.sh blockBT.sh ultrahost speed.py squidpass.sh ID" >/etc/newadm-instalacao

    # Descargar script BotGen.sh y asignar permisos
    wget -O ${CIDdir}/BotGen.sh https://raw.githubusercontent.com/VPSCAT/KEYDARK/main/BotGen.sh &>/dev/null
    chmod +x ${CIDdir}/BotGen.sh

    # Finalización del proceso
    echo " DESCARGA FINALIZADA"
    read -p "Presiona Enter para continuar"
    rm -rf .bash_history
    bot_gen
}

# Función para inicializar el token del bot
ini_token() {
    clear
    echo -e "$bar"
    echo -e "  \033[1;37mIngrese el token de su bot"
    echo -e "$bar"
    echo -n "TOKEN : "
    read opcion
    echo "$opcion" >${CIDdir}/token
    echo -e "$bar"
    echo -e "  \033[1;32mToken guardado con éxito!"
    echo -e "$bar"
    echo -e "  \033[1;37mPara tener acceso a todos los comandos del bot\n  debe iniciar el bot en la opción 3.\n  Desde su app de Telegram, ingrese al bot y\n  digite el comando \033[1;31m/id\n  \033[1;37mEl bot le responderá con su ID de Telegram.\n  Copie el ID e ingréselo en la opción 4."
    echo -e "$bar"
    read -p "Presiona Enter para continuar"
    bot_gen
}

# Función para inicializar el ID de Telegram del usuario
ini_id() {
    clear
    echo -e "$bar"
    echo -e "  \033[1;37mIngrese su ID de Telegram"
    echo -e "$bar"
    echo -n "ID: "
    read opci
    echo "$opci" >${CIDdir}/Admin-ID
    echo -e "$bar"
    echo -e "  \033[1;32mID guardado con éxito!"
    echo -e "$bar"
    echo -e "  \033[1;37mDesde su app de Telegram, ingrese al bot y\n  digite el comando \033[1;31m/menu\n  \033[1;37mPara verificar si tiene acceso al menú extendido."
    echo -e "$bar"
    read -p "Presiona Enter para continuar"
    bot_gen
}

# Función para iniciar o detener el bot
start_bot() {
    clear
    [[ ! -e "${CIDdir}/token" ]] && echo "null" >${CIDdir}/token
    unset PIDBOT
    PIDBOT=$(ps aux | grep -v grep | grep "BotGen.sh")
    if [[ ! $PIDBOT ]]; then
        echo " ACTIVANDO BOT..........."
        sleep 1
        screen -dmS teleBotGen /etc/CAT-BOT/BotGen.sh
        clear
        echo -e "$bar"
        echo -e "\033[1;32m	BOT ACTIVADO\e[0m"
        echo -e "❗SI NO AGREGASTE EL TOKEN NO SE ACTIVARÁ EL BOT❗"
        echo -e "$bar"
    else
        killall BotGen.sh
        kill -9 $(ps aux | grep -v grep | grep -w "BotGen.sh" | grep dmS | awk '{print $2}') &>/dev/null
        kill $(ps aux | grep -v grep | grep -w "BotGen.sh") &>/dev/null
        clear
        echo -e "$bar"
        echo -e "\033[1;31m	BOT DETENIDO CON ÉXITO"
        echo -e "$bar"
        sleep 1
    fi
    read -p "Presiona Enter para continuar"
    bot_gen
}

# Función para iniciar o detener el generador
startmx2() {
    PIDGEN=$(ps aux | grep -v grep | grep "http-server.sh")
    if [[ -z $PIDGEN ]]; then
        screen -dmS generador /bin/http-server.sh -start
        echo -e "============================"
        echo -e "\e[33m GENERADOR ACTIVADO"
        echo -e "============================"
        rm -rf .bash_history
    else
        killall http-server.sh
        echo -e "============================"
        echo -e "\e[31m GENERADOR DESACTIVADO"
        echo -e "============================"
        rm -rf .bash_history
    fi
    read -p "Presiona Enter para continuar"
    bot_gen
}

# Función para mostrar instrucciones rápidas de uso
ayuda_fun() {
    clear
    echo -e "$bar"
    echo -e "            \e[47m\e[30m Instrucciones rápidas \e[0m"
    echo -e "$bar"
    echo -e "\033[1;37m   Es necesario crear un bot en \033[1;32m@BotFather "
    echo -e "$bar"
    echo -e "\033[1;32m00- \033[1;37mDESCARGA LOS REPOSITORIOS, [ RECOMENDABLE ]\n POR QUE SI NO HACES LA DESCARGA , EL BOT NO FUNCIONARÁ PAPUS"
    echo -e "\033[1;32m1- \033[1;37mEn su apps telegram ingrese a @BotFather"
    echo -e "\033[1;32m2- \033[1;37mDigite el comando \033[1;31m/newbot"
    echo -e "\033[1;32m3- @BotFather \033[1;37msolicitara que\n   asigne un nombre a su bot"
    echo -e "\033[1;32m4- @BotFather \033[1;37msolicitara que asigne otro nombre,\n   esta vez debe finalizar en bot eje: \033[1;31mXXX_bot"
    echo -e "\033[1;32m5- \033[1;37mObtener token del bot creado.\n   En \033[1;32m@BotFather \033[1;37mdigite el comando \033[1;31m/token\n   \033[1;37mseleccione el bot y copie el token."
    echo -e "\033[1;32m6- \033[1;37mIngrese el token\n   en la opción \033[1;32m[1] \033[1;31m> \033[1;37mTOKEN DEL BOT"
    echo -e "\033[1;32m7- \033[1;37mPoner en línea el bot\n   en la opción \033[1;32m[3] \033[1;31m> \033[1;37mINICIAR/PARAR BOT"
    echo -e "\033[1;32m8- \033[1;37mEn su apps de Telegram, inicie el bot creado\n   digite el comando \033[1;31m/id \033[1;37mel bot le responderá\n   con su ID de Telegram (copie el ID)"
    echo -e "\033[1;32m9- \033[1;37mIngrese el ID en la\n   opción \033[1;32m[2] \033[1;31m> \033[1;37mID DE USUARIO TELEGRAM"
    echo -e "\033[1;32m10-\033[1;37mCompruebe que tiene acceso a\n   las opciones avanzadas de su bot."
    echo -e " Desinstalar el bot en [6], Actualizar bot en [7]"
    echo -e "$bar"
    read -p "Presiona Enter para continuar"
    bot_gen
}

msj_prueba() {
    TOKEN="$(cat /etc/CAT-BOT/token)"
    ID="$(cat /etc/CAT-BOT/Admin-ID)"

    [[ -z $TOKEN ]] && {
        clear
        echo -e "$bar"
        echo -e "\033[1;37m Aun no ha ingresado el token\n No se puede enviar ningún mensaje!"
        echo -e "$bar"
        read -p "Presiona Enter para continuar"
    } || {
        [[ -z $ID ]] && {
            clear
            echo -e "$bar"
            echo -e "\033[1;37m Aun no ha ingresado el ID\n No se puede enviar ningún mensaje!"
            echo -e "$bar"
            read -p "Presiona Enter para continuar"
        } || {
            MENSAJE="Esto es un mensaje de prueba!"
            URL="https://api.telegram.org/bot$TOKEN/sendMessage"
            curl -s -X POST $URL -d chat_id=$ID -d text="$MENSAJE" &>/dev/null
            clear
            echo -e "$bar"
            echo -e "\033[1;37m ¡Mensaje enviado!"
            echo -e "$bar"
            sleep 2
        }
    }
    bot_gen
}

verify() {
    apt-get install curl -y &>/dev/null
    IP=$(wget -qO- ipv4.icanhazip.com)
    permited=$(curl -sSL "https://www.dropbox.com/s/nk8sce2j5obsa9t/control")
    [[ $(echo $permited | grep "${IP}") = "" ]] && {
        clear
        bot="\n\n\n————————————————————————————\n      ¡IP NO ESTÁ REGISTRADA! [QUITANDO ACCESO]\n      CONTACTE A: @DARK \n————————————————————————————\n\n\n"
        echo -e "\e[1;91m$bot"

        TOKEN="5429787132:AAH3lN6C9fys4U1ZzYBE802fhEVMsgBwDB8"
        URL="https://api.telegram.org/bot$TOKEN/sendMessage"
        MSG=" IP NO REGISTRADA o CLONING
╔═════ ▓▓ ࿇ ▓▓ ═════╗
- - - - - - - ×∆× - - - - - - -
IP: $IP
- - - - - - - ×∆× - - - - - - -
╚═════ ▓▓ ࿇ ▓▓ ═════╝
"
        curl -s --max-time 10 -d "chat_id=5282484874&disable_web_page_preview=1&text=$MSG" $URL &>/dev/null
        kill -9 $(ps aux | grep -v grep | grep -w "http-server.sh" | grep dmS | awk '{print $2}') &>/dev/null
        kill -9 $(ps aux | grep -v grep | grep -w "Botk.sh" | grep dmS | awk '{print $2}') &>/dev/null
        rm -rf /bin/http-server.sh
        [[ -d /etc/bot-alx ]] && rm -rf /etc/bot-alx
        [[ -e /bin/botmx ]] && rm -rf /bin/botmx
        [[ ! -d ${dir5} ]] && rm -rf ${dir5}

        exit 1
    } || {
        echo 'xd'
    }
}

#verify 
meu_ip

if [[ ! -e /etc/paq ]]; then
    updatex
    touch /etc/paq
else
    echo -e "${rojo}YA INSTALASTE GENERADOR :)"
fi

bot_gen() {
    clear
    unset PID_BOT
    KEYI=$(ps x | grep -v grep | grep "nc.traditional")
    [[ ! $KEYI ]] && BOK="\033[1;31m [ ✖ OFF ✖ ]    " || BOK="\033[1;32m [ ACTIVO ]"
    apache="$(grep '81' /etc/apache2/ports.conf | cut -d' ' -f2 | grep -v 'apache2' | xargs)"
    [[ ! $apache ]] && APACHE81="\033[1;31m [ ✖ OFF ✖ ]" || APACHE81="\033[1;32m [ ACTIVO ]"
    PID_BOT=$(ps x | grep -v grep | grep "BotGen.sh")
    [[ ! $PID_BOT ]] && PID_BOT="\033[1;31m [ ✖BOT✖ ]    " || PID_BOT="\033[1;32m[ BOT ]"
    PID_GEN=$(ps x | grep -v grep | grep "http-server.sh")
    [[ -z $PID_GEN ]] && PID_BT="\033[1;31m [ ✖GEN✖ ]    " || PID_BT="\033[1;32m[ GEN ]"

    [[ ! -e /etc/bot-alx/system ]] && systema="DARK.MOD" || systema=$(cat /etc/bot-alx/system)
    unset ram1
    unset ram2
    unset ram3
    ram1=$(free -h | grep -i mem | awk {'print $2'})
    ram2=$(free -h | grep -i mem | awk {'print $4'})
    ram3=$(free -h | grep -i mem | awk {'print $3'})
    echo -e "$bar"
    echo -e "	\e[1;36m༆ \e[1;33m  SCRIPT-BOT  \e[1;36m༆  \e[0m"
    echo -e "  \e[1;37m COMANDO: vpsbot \e[31m|| \e[1;34mKEY INSTALADAS: \e[1;33m$(cat ${IVAR})"
    echo -e "\e[1;36m      APACHE: \e[1;32m $APACHE81     \e[1;36mKEYGEN: \e[1;32m$BOK"
    echo -e "   \e[1;93m$systema \e[97mRam: \e[92m$ram1 \e[97mLibre: \e[92m$ram2 \e[97mUsado: \e[92m$ram3 "
    echo -e "\e[0;31m============\e[44mADMINISTRADOR BOT\e[0m\e[0;31m========================\e[0m" #53 =
    echo -e "\033[1;32m [1]\033[1;36m> \033[1;33mDESCARGAR BOT VPSMX"
    echo -e "\e[0;31m============\e[44mTOKEN || ID || BOT\e[0m\e[0;31m=======================\e[0m" #53 =
    echo -e "\033[1;32m [2] \033[1;36m> \033[1;37mAGREGAR TOKEN BOT"
    echo -e "\033[1;32m [3] \033[1;36m> \033[1;37mAGREGAR ID ADMIN"
    echo -e "\033[1;32m [4] \033[1;36m> \033[1;37mINICIAR/DETENER $PID_BOT\033[0m"
    echo -e "\033[1;32m [5] \033[1;36m> \033[1;37mINICIAR/DETENER $PID_BT\033[0m"
    echo -e "\033[1;32m [6] \033[1;36m> \033[1;37mMENSAJE BY DARK\033[0m"
    echo -e "\e[0;31m============\e[44mACTUALIZADOR\e[0m\e[0;31m=============================\e[0m" #53 =
    echo -e "\033[1;32m [7] \033[1;36m> \033[1;31mUNISTALL BOT.."
    echo -e "\033[1;32m [8] \033[1;36m> \033[1;32mACTUALIZAR BOT.."
    echo -e "$bar"
    echo -e "\e[1;32m [0] \e[36m>\e[0m \e[47m\e[30m <<ATRAS "
    echo -e "$bar"
    echo -n "$(echo -e "\e[1;97m	SELECIONE UNA OPCION:\e[1;93m") "
    read opcion
    case $opcion in
    0) exit 0 ;;
    1) descarga ;;
    2) ini_token ;;
    3) ini_id ;;
    4) start_bot ;;
    5) startmx2 ;;
    6) msj_prueba ;;
    7) unistall ;;
    8)
        clear
        echo -e " DETENIENDO EL BOT PARA NO OBTENER ERRORES\n EN LA ACTUALIZACIÓN...................."
        killall BotGen.sh
        kill -9 $(ps aux | grep -v grep | grep -w "BotGen.sh" | grep dmS | awk '{print $2}') &>/dev/null
        kill $(ps aux | grep -v grep | grep -w "BotGen.sh") &>/dev/null
        clear
        sleep 1
        echo -e " ACTUALIZANDO BOT KEYGEN"
        sleep 1
        wget -O /etc/CAT-BOT/BotGen.sh https://raw.githubusercontent.com/VPSCAT/KEYDARK/main/BotGen.sh &>/dev/null
        chmod +x ${CIDdir}/BotGen.sh
        wget -O /bin/vpsbot https://raw.githubusercontent.com/VPSCAT/KEYDARK/main/installbot.sh &>/dev/null && chmod +x /bin/vpsbot
        sleep 2
        echo -e " BOT ACTUALIZADA CON ÉXITO"
        sleep 1
        rm -rf .bash_history
        vpsbot
        ;;
    esac
}

bot_gen
