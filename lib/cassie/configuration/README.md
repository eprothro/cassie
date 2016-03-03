# Cassie Configuration

Cassie provides cluster configuration storage and retrieval.

`Cassie` extends `Configuration::Core`, providing functionality to act as a configuration handler.

```ruby
Cassie.env
=> "development"

Cassie.configurations
=> {"development"=>{"hosts"=>["127.0.0.1"], "port"=>9042, "reconnection_policy"=>nil, "keyspace"=>"my_app_development"}, "test"=>{"hosts"=>["127.0.0.1"], "port"=>9042, "idle_timeout"=>"nil", "keyspace"=>"my_app_test"}, "production"=>{"hosts"=>["cass1.my_app.biz", "cass2.my_app.biz", "cass3.my_app.biz"], "port"=>9042, "keyspace"=>"my_app_production"}}

Cassie.configuration
=> {"hosts"=>["127.0.0.1"], "port"=>9042, "reconnection_policy"=>nil, "keyspace"=>"my_app_development"}

Cassie.keyspace
=> "my_app_development"
```

The env supports loading from the environment, by default, as follows:
```
ENV["CASSANDRA_ENV"] || ENV["RACK_ENV"] || "development"
```
It may also explicitly be set via `Cassie.env=`.

#### Usage

Cassie also acts as a connection handler. It uses the above configuration functionality to instantiate a `Cassandra::Cluster` using the desired configuration and connect `Cassandra::Sessions`.

See the [Connection README](./lib/cassie/connection_hanlder/README.md#readme) for more on features and usage.]

#### Advanced / Manual Usage

A YAML backend is provided by default. Run `cassie configuration:generate` to generate the configuration file. The default location for these cluster configurations is `config/cassandra.yml`. This is configurable.

```ruby
$ cassie configuration:generate cassandra_clusters.yml
$ irb
irb(main):001:0> require 'cassie'
=> true
irb(main):002:0> Cassie.paths
=> {"cluster_configurations"=>"config/cassandra.yml"}
irb(main):003:0> Cassie.paths["cluster_configurations"] = 'cassandra_clusters.yml'
=> "cassandra_clusters.yml"
irb(main):004:0> Cassie.configurations
=> {"development"=>{"hosts"=>["127.0.0.1"], "port"=>9042, "reconnection_policy"=>nil, "keyspace"=>"my_app_development"}, "test"=>{"hosts"=>["127.0.0.1"], "port"=>9042, "idle_timeout"=>"nil", "keyspace"=>"my_app_test"}, "production"=>{"hosts"=>["cass1.my_app.biz", "cass2.my_app.biz", "cass3.my_app.biz"], "port"=>9042, "keyspace"=>"my_app_production"}}
irb(main):005:0>
```

`configurations`, `env`, `configuration` and `keyspace` may be set explicitly as well.

```
Cassie.configuration = {"hosts"=>["localhost"], "port"=>9042, "keyspace"=> 'my_default_keyspace'}
```

> *Note:* Setting the `configuration` explicitly naturally means that `configurations` and `env` will no longer have functional meaning.
