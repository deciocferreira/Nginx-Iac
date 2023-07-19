<p align="center"> <image src="https://github.com/deciocferreira/Nginx-Iac/assets/12403699/02185bcd-f7ac-485f-9855-2fe2eab4b1e3" width="120" height="120">  <image src="https://github.com/deciocferreira/Nginx-Iac/assets/12403699/022c28ce-6630-4bfc-b73e-c9aa56bf3b37" width="100" height="100"> </p>
<h1 align ="center"> Iac + NGINX </h1>

<p align ="center"> Projeto para implantação do Nginx server escalável, utilizando infraestrutura da AWS criada pelo Terraform. </p>

&nbsp;

## Proposta de tecnologias e arquitetura para a solução.

- **VPC e Rede**: Uma Virtual Private Cloud com sub-redes públicas e privadas para distribuir as instâncias ECS, security groups configurados para controlar o tráfego entre as instâncias e uma a rota para o Gateway NAT, para que as instâncias na sub-rede privada acessem a Internet.

- **ECR (Elastic Container Registry)**: Armazenamento da imagem do container Nginx.

- **ECS (Elastic Container Service)**: O ECS será responsável em executar e dimensionar os containeres do nginx através de uma definição de tarefa (task definition) para o nginx usando a imagem do ECR criada anteriormente.
  
- **ELB (Elastic Load Balancer)**: Distribuição do tráfego entre as instâncias em execução feita por um Application Load Balancer.

- **EC2 Auto Scaling**: Permite que haja dimensionamento automático para escalar as instâncias ECS com base na utilização de CPU e memória.

- **CloudWatch**: Habilita o monitoramento das instâncias, coleta logs e alertas com base em métricas como CPU e memória.

- **Terraform**: Ferramenta Iac para criação dos recursos na AWS.
