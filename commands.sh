docker build --build-arg="GITHUB_USERNAME=<username>" .
# If I did this for work, I would use Syft and Grype from a pipeline or github actions. I could also use them as an init container inside a deployment for Kubernetes.
# The container registry used might also have security scanning tools.
docker run --rm --volume /var/run/docker.sock:/var/run/docker.sock --name Grype anchore/grype:latest <image_id>
docker run --rm --volume /var/run/docker.sock:/var/run/docker.sock --name Syft anchore/syft:latest <image_id>