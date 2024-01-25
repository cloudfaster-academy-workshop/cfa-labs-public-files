#!/bin/bash

## Arquivo de inicialização da CloudFaster Academy
# Criacao: 23-01-2024
# Ultima Alteracao: 23-01-2024

# obtem o token de meta-tags da instancia
status_code=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -o "inittemp.txt" -w "%{http_code}"`
if [ $status_code -eq 200 ]; then
  token=`cat inittemp.txt`
  rm inittemp.txt
  # busca a meta-tag Name da instancia
  status_code=`curl -s -GET "http://169.254.169.254/latest/meta-data/tags/instance/Name" -H "X-aws-ec2-metadata-token: $token" -o "inittemp.txt" -w "%{http_code}"`
  if [ $status_code -eq 200 ]; then
    instance_name=`cat inittemp.txt`
    rm inittemp.txt
  else
    # busca a meta-tag instance-id da instancia
    status_code=`curl -s -GET "http://169.254.169.254/latest/meta-data/instance-id" -H "X-aws-ec2-metadata-token: $token" -o "inittemp.txt" -w "%{http_code}"`
    instance_name=`cat inittemp.txt`
    rm inittemp.txt
  fi
  # verifica se existe um nome de instancia
  if [ ! -n "$instance_name" ]; then
    numero_aleatorio=$((RANDOM % 26))
    letra_aleatoria=$(printf \\$(printf '%03o' $((65 + numero_aleatorio))))
    instance_name="EC2_$letra_aleatoria"
  fi
  # baixa o index.html
  wget -q -O index_temp.html https://assets.cloudfaster.academy/danrezende/htmls/index-ec2.html
  sed "s/{INSTANCENAME}/$instance_name/g" index_temp.html > /var/www/html/index.html
  rm index_temp.html
  # adicionando entrada no cron
  # yum install cronie -y
  # systemctl enable crond.service
  # systemctl start crond.service
  echo "* * * * * /usr/local/init_faster.sh" > /usr/local/new_crontab
  crontab /usr/local/new_crontab
  rm /usr/local/new_crontab
  echo "Configuracao ok"
else
  echo "Não foi possivel obter token de acesso..."
fi
