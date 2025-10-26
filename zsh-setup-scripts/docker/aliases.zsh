#!/usr/bin/env zsh

if command -v docker &> /dev/null; then
    log_success "Docker is installed, setting up aliases"
    alias d='docker'
    alias d-c='docker-compose'
    alias d-k='docker kill'
    alias d-rm='docker rm'
    alias d-rmi='docker rmi'
    alias d-ps='docker ps'
    alias d-pull='docker pull'
    alias d-push='docker push'
    alias d-build='docker build'
    alias d-logs='docker logs -f'
    alias d-exec='docker exec -it'
    alias d-start='docker start'
    alias d-stop='docker stop'
    alias d-stats='docker stats'
    alias d-images='docker images'
    alias d-networks='docker network ls'
    alias d-volumes='docker volume ls'
    alias d-inspect='docker inspect'
    alias d-compose='docker-compose'
    alias d-compose-up='docker-compose up -d'
    alias d-compose-down='docker-compose down'
    alias d-compose-logs='docker-compose logs -f'
    alias d-compose-build='docker-compose build'
    alias d-compose-ps='docker-compose ps'
    alias d-compose-pull='docker-compose pull'
    alias d-compose-push='docker-compose push'
    alias d-compose-exec='docker-compose exec'
    alias d-compose-start='docker-compose start'
    alias d-compose-stop='docker-compose stop'


    # For Mac OS Silicon M1/M2/M3, you can set DOCKER_FORCE_AMD64=1 to automatically
    # use --platform linux/amd64 for all 'docker run' and 'docker build' commands.
    # This is opt-in to avoid unexpected behavior.
    #
    # To enable, add to your .zshrc or environment:
    #   export DOCKER_FORCE_AMD64=1
    #
    # Alternatively, use the explicit alias:
    #   alias docker-x86="docker --platform linux/amd64"
    
    if [[ `uname -m` == "arm64" ]]; then
        # Provide explicit alias for x86 compatibility
        alias docker-x86='docker --platform linux/amd64'
        
        # Only override docker command if explicitly requested
        if [[ -n "$DOCKER_FORCE_AMD64" ]]; then
            docker() {
                if [[ "$1" == "run" || "$1" == "build" ]]; then
                    command docker "$1" --platform linux/amd64 "${@:2}"
                else
                    command docker "$@"
                fi
            }
            log_success "Docker ARM64 platform override enabled (DOCKER_FORCE_AMD64 set)"
        else
            log_debug "Docker ARM64 platform override available (set DOCKER_FORCE_AMD64=1 to enable)"
        fi
    fi
else
    log_skip "Docker not found, skipping Docker aliases"
    return
fi
