#ddev-generated
ARG BASE_IMAGE
FROM $BASE_IMAGE

# Add custom entrypoint
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# delete the default 'node' user with uid 1000 and add current ddev user
ARG username
ARG uid
ARG gid
RUN userdel -r node
RUN (groupadd --gid $gid "$username" || groupadd "$username" || true) && (useradd  -l -m -s "/bin/bash" --gid "$username" --comment '' --uid $uid "$username" || useradd  -l -m -s "/bin/bash" --gid "$username" --comment '' "$username" || useradd  -l -m -s "/bin/bash" --gid "$gid" --comment '' "$username" || useradd -l -m -s "/bin/bash" --comment '' $username )

# Add sudo and sudoers in manner similar to other ddev containers
RUN apt update && apt install -y sudo; apt clean -qq && rm -rf /var/lib/apt/lists/*; echo "ALL ALL=NOPASSWD: ALL" > /etc/sudoers.d/ddev-backstop && chmod 440 /etc/sudoers.d/ddev-backstop

# Install mkcert
RUN apt update --fix-missing; apt install -y curl libnss3-tools; curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"; chmod +x mkcert-v*-linux-amd64; cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert

USER $username