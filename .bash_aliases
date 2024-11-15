alias la='ls -Aohp --group-directories-first'
alias ll='ls -A --group-directories-first'
alias l='ls -CF'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias suspend='systemctl suspend'
alias dirsize='du --human-readable --all --max-depth=1 | sort --human-numeric-sort'

# [e]dit [c]onfig [b]ash_[a]liases
alias ecba='nvim ~/.bash_aliases'
# [e]dit [c]onfig [b]ash
alias ecb='nvim ~/.bashrc'
# [e]dit [c]onfig [i]3
alias eci='nvim ~/.config/i3/config'
# [e]dit [c]onfig [n]vim
alias ecn='nvim ~/.config/nvim/init.lua'
# [e]dit [c]onfig [a]lacritty
alias eca='nvim ~/.config/alacritty/alacritty.toml'
# [e[]dit [c]onfig [s]sh
alias ecs='nvim ~/.ssh/config'

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
complete -o bashdefault -o default -o nospace -F __git_wrap__git_main config
_completion_loader git

alias rts='cd ~/programming/go/RTS-Game-Engine'

alias clearnamespace='kubectl delete namespace $(currentnamespace) ; kubectl create namespace $(currentnamespace)'
alias currentnamespace="kubectl config view --minify -o jsonpath='{..namespace}'; echo"
alias getnamespace=currentnamespace

alias ta='tmux attach'

alias vi='nvim'
alias vim='nvim'

function md() {
	mkdir --parent $1
	cd $1
}

function getpass() {
	kubectl get secrets <NAME> --output jsonpath='{.data.password}' | base64 --decode
}

function kubectltop() {
	kubectl top pod $@ --containers --no-headers | sort --reverse --key 4 --numeric
}

function clusternodes() {
	watch "kubectl get pods -o custom-columns=:.metadata.name --no-headers --selector 'app.kubernetes.io/name=my-cluster' | parallel -k 'echo {}; kubectl exec {} -c redis-node -- cli cluster nodes | sort; echo ""'"
}

function setnamespace() {
	if [[ -z "$1" ]]; then
		echo "Using namespace ermahna"
		kubectl config set-context --current --namespace ermahna > /dev/null
		return
	fi

	ns="$1"
	echo "Using namespace ${ns}"
	kubectl config set-context --current --namespace ${ns} > /dev/null
}

# takes 1 or 2 parts of a name and tries to find a matching pod
function getPod() {
	# grep 1 match (-m 1) and only print the matching part (-o)
	# zero or more characters ( \S* )
	POD="$(kubectl get pods | grep -m 1 -o \\S*$1\\S*$2\\S*)"
	# echo "POD = $POD"
}

# Parse args: https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
function savelogs() {
	CONTAINER=""
	POD_P1=""
	POD_P2=""
	POD=""
	PREVIOUS=""
	TIMESTAMP=""
	while [[ $# -gt 0 ]]; do
		case $1 in
			-c|--container)
				CONTAINER="-c $2"
				shift # past argument
				shift # past value
				;;
			--previous)
				PREVIOUS="--previous"
				shift # past argument
				;;
			-t|--timestamp)
				TIMESTAMP="-t"
				shift
				;;
			*)
				if [ -z "$POD_P1" ]; then
					POD_P1="$1"
				else
					POD_P2="$1"
				fi
				shift # past arg
				;;
		esac
	done

	getPod $POD_P1 $POD_P2

	if [[ "$POD" == *"operand"* ]] && [[ "$CONTAINER" == "" ]]; then
		CONTAINER="-c redis-node"
	fi

	kubectl logs $POD $CONTAINER $PREVIOUS | logparse $TIMESTAMP > l.txt
}

