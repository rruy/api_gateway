## API Gateway

O objetivo desse projeto é a construção de uma API gateway que contenha um mecanismo de RateLimit de requests e métricas de consumo de processamento de requisições.

### Requerimentos
Requerimentos para instalar e rodar o projeto. 

- Ruby 2.7.2
- Rails 7.0.3
- PostgreSQL
- Redis
- Rspec

### Instruções de instalação
Para instalar e rodar o projeto você precisa executar os seguintes comandos na pasta raiz do projeto via prompt de comando:

Comando:
```
$ bundle install
$ rake db:create db:migrate
$ rails s
```

Caso ocorra algum erro ao gerar a base de dados provalvemento pode ser o usuario e senha configurados no arquivo /config/database.yml

Exemplo:
```
default: &default
  adapter: postgresql
  encoding: unicode
  host: localhost
  user: postgres
  password: postgres
```

### Arquitetura 
Basicamente uma API Gateway é responsável por receber uma requisição de um cliente e direcionar para outros servidores que podem atende-lo e retorna a resposta ao cliente. Essa solução foi concebida para facilitar o gerenciamento de integração de clientes aos invés de disponibilizar diversos endpoints de microserviços distintos. Com isso facilita a integração de sistemas e permite a escalabilidade das aplicações da stack. 

![Api Gateway](/public/apigateway.png)

Quando não é adotado um pattern de API Gateway podemos ter os seguintes problemas:

- Falta de encapsulamento: 
a UI conhece detalhes sobre a implementação do sistema como um todo. E isso é problemático porque a implementação muda constantemente: novos serviços serão criados, outros serviços alterados ou divididos. A cada alteração, a UI deverá ser modificada em conjunto com os serviços modificados.
- Segurança: 
Sob uma perspectiva de Segurança da Informação, há uma grande superfície exposta na Arquitetura atual da empresa Ac,e. Cada serviço exposto pode ser alvo de ataques.

Existem outras formas de resolver esse desafio como configuração do Nginx, ou utilizar o serviço da AWS API Gateway. No projeto desse repositório foi escolhida a opção de implementar um proxy reverso baseado no protocolo http.

##### Rate Limit

O controle de tráfego e consumo da API foi elaborado para suportar uma quantidade específica de requisições baseado na configuração que é realizada no arquivo applications.rb. É possível estabelecer os seguintes tipos de controles: 

- Controle por quantidade de requisições por minuto, horas e dias. 
- É possivel estabelecer uma quantidade x de requisições que poderá ser realizada em um endpoint específico. 
- Existe a possibilidade de combinar as duas condições, endpoint + tipo de métrica(minuto, hora, dias).

Para realizar a configurações desejadas deve ser alterado no arquivo application.rb com os seguintes códigos dentro do bloco específico demilitado para o RateLimit conforme exemplo abaixo. 

```
config.middleware.use RateRequest do |r|
   r.define_rule(match: '/api/v1/cards', metric: rpm, type: :fixed, limit: 10.to_i, per_url: true)
   r.define_rule(match: '/api/v1/cards', metric: rph, type: :fixed, limit: 10.to_i, per_url: true)
   r.define_rule(match: '/api/v1/cards', metric: rpd, type: :fixed, limit: 10.to_i, per_url: true)
end
```
No parametro metric: podemos usar uma das opções [rpm, rph, rpd] onde são respectivamentes o controle por minuto, hora e dias.

No parametro limit: estabelecemos a quantidade de request que um cliente pode realizar. 

Para armazenamento de dados de requests podemos utilizar o cache nativo do Rails, mas para sistemas em autoscaling devomos usar a configuração do REDIS para armazenamento compartilhado entre as instâncias do API Gateway.


##### Endpoints
Lista de endpoints disponíveis para consulta


Enpoint raiz do projeto
```
http: //localhost:3000/api/v1/entrypoint
```

Perrmite consumir os dados de cartões através da API gateway - Enpoint chama o Server 01
```
GET http: //localhost:3000/api/v1/cards
```
Perrmite consumir os dados de catalogos através da API gateway - Enpoint chama o Server 02

```
GET http: //localhost:3000/api/v1/catalogs
```

Perrmite consumir os dados de produtos através da API gateway - Enpoint chama o Server do IBGE

```
GET http: //localhost:3000/api/v1/produtos
```

##### Estatisticas de consulmo da api
Log de acessos da API contendo todos os requests
```
GET http: //localhost:3000/api/v1/requests
```

Log de acessos da API contendo todos os requests que apresentaram erros
```
GET http: //localhost:3000/api/v1/requests/errors
```

Retorna a quantidade de requests na hora atual na API
```
GET http: //localhost:3000/api/v1/requests/per_hours
```

Retorna a quantidade de requests na dia atual na API
```
GET http: //localhost:3000/api/v1/requests/per_day
```


### Executar os testes unitários
Para instalação caso não seja reconhecido o comando rspec:
```
$ gem install rspec
```
Para executar os testes unitários rode o seguinte comando:
```
$ rspec spec/
```
O resulta na saida do terminal deve ser algo parecido com a linha abaixo:
```
Finished in 0.02098 seconds (files took 0.10544 seconds to load)
26 examples, 0 failures
```

#### Desafio proposto
A empresa ACME possui atualmente +30.000 servidores onde suas aplicações são
executadas. Elas comunicam-se entre si através de apis, sendo que algumas possuem
ainda acesso externo (api.acme.com). 

Um dos problemas que temos é como controlar e medir estas interconexões
Para isso, precisamos implementar (codifique) um "proxy de apis" com os seguintes
requisitos (em ordem de importância):
- Executar a função de proxy sobre o domínio api.acme.com, isto é, ele
deve agir como um intermediário para as requisições dos clientes, enviando-as à
api.acme.com.
- Deverá permitir o controle das quantidades máximas de requisições por:
   ```
   - IP de origem
   - Path de destino
   - Combinações de ambos
   - Outros critérios ou alternativas de controle são bem vindos
   ```
- Deve armazenar (e também permitir que se consulte) as estatísticas de uso do
proxy.

- O proxy (como solução) deverá poder superar 50.000 requisições por segundo.

#### Evolução deste projeto 

Para próximos passos seria interessante incluir uma camada de autentição via token JWT e usar o padrão o oAuth para autenticação. Com isso podemos garantir que quem está acessando é realmente que deve ter acesso nos endpoints, principalmente quando ocorrer chamadas externas. 


