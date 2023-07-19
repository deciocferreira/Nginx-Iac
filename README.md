<p align="center"> <image src="https://github.com/deciocferreira/nginx-iac/assets/12403699/5d9be2ff-5c72-4730-9183-08da79c0aadd" width="120" height="120">  <image src="https://github.com/deciocferreira/nginx-iac/assets/12403699/4bd2021f-9739-419f-b3db-48abe05f5e3a" width="100" height="100"> </p>
<h1 align ="center"> Iac + NGINX </h1>

<p align ="center"> Projeto para implantação do Nginx server escalável, utilizando infraestrutura da AWS criada pelo Terraform. </p>

&nbsp;

## Proposta de tecnologias e arquitetura para a solução.

- **VPC e Rede**: Uma Virtual Private Cloud com sub-redes públicas e privadas para distribuir as instâncias ECS e security groups configurados para controlar o tráfego entre as instâncias.

- **ECR (Elastic Container Registry)**: Armazenamento da imagem do container Nginx.

- **ECS (Elastic Container Service)**: O ECS será responsável em executar e dimensionar os containeres do nginx através de uma definição de tarefa (task definition) para o nginx usando a imagem do ECR criada anteriormente.
  
- **ELB (Elastic Load Balancer)**: Distribuição do tráfego entre as instâncias ECS em execução.

- **EC2 Auto Scaling**: Permite que haja dimensionamento automático para escalar as instâncias ECS com base na utilização de CPU e memória.

- **CloudWatch**: Habilita o monitoramento das instâncias, coleta logs e alertas com base em métricas como CPU e memória.

- **Terraform**: Ferramenta Iac para criação dos recursos na AWS.
