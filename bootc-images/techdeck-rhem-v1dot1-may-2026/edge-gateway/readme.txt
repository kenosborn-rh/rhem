3-May-26 Note from Ken

I used this build to test v1.1 in my Homelab when creating v1.1 Tech Deck slides

This build also uses the downstream repo's for the RHEM agent which means it needs to use the hosts subscription-manager entitlement to install the agent vs. upstream.  In order to get this to work (and I don't know if this is the 'right way' or not), I had to:

sudo mkdir -p rhsm-build/etc rhsm-build/pki

sudo cp -a /etc/rhsm rhsm-build/etc/
sudo cp -a /etc/pki/entitlement rhsm-build/pki/

put this in the Containerfile block for the agent install:

RUN --mount=type=bind,src=rhsm-build/etc/rhsm,target=/etc/rhsm,ro \
    --mount=type=bind,src=rhsm-build/pki/entitlement,target=/etc/pki/entitlement,ro \
    dnf clean all && \
    dnf -y --enablerepo=edge-manager-1.1-for-rhel-9-x86_64-rpms \
      install flightctl-agent-0:1.1.1-1.el9em.x86_64 && \
    systemctl enable flightctl-agent.service

Also:
so build secrets aren't published to git:
echo "rhsm-build/" >> .gitignore

I didn't do this but this would have been thorough to remove local build secrets:
sudo rm -rf rhsm-build

This advice was from ChatGPT, here:
https://chatgpt.com/share/69f77ecc-9908-83ea-aa5f-52aeaba6ff3d

This build was topical because it was the same one we used for the Summit Train Demo (Edge Gateway)

That train demo build is sourced in /git/summit-2026-train-demo/gateway-builds/bootc...