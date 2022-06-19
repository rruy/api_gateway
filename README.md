## API Gateway

O objetivo desse projeto é a construção de uma API gateway que receba uma requisição cliente e seja responsável pelo redirecionamento para o microservico destino. Após o processamento deve ser retornado para o cliente a resposta da requisição. Além disso a Api tem um controle de requisições onde é possível configurar o controle de chamadas por minuto, por hora, por dia e por endpoints especificos para evitar requisições além da capacidade da API e garantir a estabilidade do serviço.

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

![Api Gateway](/public/apigateway.jpg)

Quando não é adotado um pattern de API Gateway podemos ter os seguintes problemas:

- Falta de encapsulamento: 
a UI conhece detalhes sobre a implementação do sistema como um todo. E isso é problemático porque a implementação muda constantemente: novos serviços serão criados, outros serviços alterados ou divididos. A cada alteração, a UI deverá ser modificada em conjunto com os serviços modificados.
- Segurança: 
Sob uma perspectiva de Segurança da Informação, há uma grande superfície exposta na Arquitetura atual da empresa Ac,e. Cada serviço exposto pode ser alvo de ataques.

Existem outras formas de resolver esse desafio como configuração do Nginx, ou utilizar o serviço da AWS API Gateway. No projeto desse repositório foi escolhida a opção de implementar um proxy reverso baseado no protocolo http.

Explicação: 

TODO: Escrever a explicação do projeto. 




##### Endpoints
Lista de endpoints disponiveis para consulta
```
http: //localhost:3000/api/v1/entrypoint
```
```
http: //localhost:3000/api/v1/cards
```
```
http: //localhost:3000/api/v1/catalogs
```

##### Estatisticas de consulmo da api
Log de acessos da API
```
http: //localhost:3000/api/v1/requests
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
 -- IP de origem
 -- Path de destino
 -- Combinações de ambos
 -- Outros critérios ou alternativas de controle são bem vindos

- Deve armazenar (e também permitir que se consulte) as estatísticas de uso do
proxy.

- O proxy (como solução) deverá poder superar 50.000 requisições por segundo.

#### Evolução deste projeto 

Para próximos passos seria interessante incluir uma camada de autentição via token JWT e usar o padrão o oAuth para autenticação. Com isso podemos garantir que quem está acessando é realmente que deve ter acesso nos endpoints, principalmente quando ocorrer chamadas externas. 


