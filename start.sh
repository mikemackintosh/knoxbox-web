docker kill knoxboxweb
docker rm knoxboxweb
truncate ./logs/* --size 0 2>/dev/null

docker run -d -v $(pwd)/logs:/var/log/supervisor \
    -p 80:80 \
    -p 443:443 \
    -p 1194:1194 \
  --name knoxboxweb mikemackintosh/knoxboxweb
