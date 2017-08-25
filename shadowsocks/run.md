# Run on the server side, make sure 28666/udp and 28777/tcp is allow in your VPC's firewall
docker run -dt --name socketproxy-server \
	-p 28777:28777 -p 28666:28666/udp \
	kevinwangcy/upchain:socketproxy-3.0.6-20170329 \
	-m "ss-server" \
	-s "-s 127.0.0.1 -p 28777 -k <replace with your key> -m aes-128-cfb -d 127.0.0.1" \
	-n "kcptun-server" \
	-k "-l :28666 -t 127.0.0.1:28777 --crypt none --nocomp --mtu 1440 --mode fast --dscp 46 -sndwnd 8000" \
	-x

# try removing the -d parameter from above if the DNS doesn't work properly
docker run -dt --name socketproxy-server \
	-p 28777:28777 -p 28666:28666/udp \
	kevinwangcy/upchain:socketproxy-3.0.6-20170329 \
	-m "ss-server" \
	-s "-s 127.0.0.1 -p 28777 -k <replace with your key> -m aes-128-cfb" \
	-n "kcptun-server" \
	-k "-l :28666 -t 127.0.0.1:28777 --crypt none --nocomp --mtu 1440 --mode fast --dscp 46 -sndwnd 8000" \
	-x

# Run on your client host side.
mkdir -p /var/log/socketproxyps

docker run -dt --name socketproxy-local \
	-p 28777:28777 -p 28666:28666/udp -p 8888:8888 \
	-v /var/log/socketproxy:/var/log/socketproxy \
	kevinwangcy/upchain:socketproxy-3.0.6-20170329 \
	-m "ss-local" \
	-s "-s 127.0.0.1 -p 28777 -k <replace with your key> -m aes-128-cfb -l 8888 -b 0.0.0.0 -v 2> /var/log/socketproxy/log.txt" \
	-n "kcptun-client" \
	-k "-l 127.0.0.1:28777 -r <your VPS's ip address>:28666 --crypt none --nocomp --mtu 1440 --mode fast --dscp 46 -sndwnd 300 -rcvwnd 8000 -conn 12" \
	-x

# define proxy.pac to use your proxy, maintain domain array to exclude those domains bypass proxy
var domains = {
    "cuaa.net":0, "vipcn.com":0
};

function isLocalIPv4(host) {
    var re_ipv4 = /^\d+\.\d+\.\d+\.\d+$/;
    var re_local_ipv4 = /(^127\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/;

    if (re_ipv4.test(host)) {
        return re_local_ipv4.test(host);
    }

    return false;
}

function isInDomains(host) {
    var pos = 0;
    do {
        if (domains.hasOwnProperty(host)) {
            return true;
        }
        pos = host.indexOf(".") + 1;
        host = host.slice(pos);
    } while(pos > 1);

    return false;
}

/**
 * @return {string}
 */
function FindProxyForURL(url, host) {
    if (isInDomains(host) || isLocalIPv4(host) || isPlainHostName(host)) {
        return "DIRECT";
    }

    return "SOCKS5 <client host ip address>:8888; SOCKS <client host ip address>:8888";
}



