# How to Contribute

## Bugs

A pull request with a failing test is the best way to report an issue.

If you are unable to reproduce with a failing test, try again :). If you're still unable, open an issue.

To run the unit suite:
  * Fork the repo and then clone with `git clone https://github.com/YOUR-USERNAME/cassie`
  * Install the bundle with `bundle`
  * Run `rake spec`

If you need a real Cassandra connection to reproduce. To run the integration suite:
  * Follow above instructions
  * Ensure Cassandra is running and accepting connecitons on port 9042 (the default)
  * Run `rake full_spec`

## Ideas

Feel more than free to open an issue for conversation about any ideas or suggestions.


## Making Changes

### Unit tests

Unit tests should provide complete coverage of features and should not depend on an available Cassandra server.


### Integration tests depending on database

Integration tests that rely on a Cassandra server exist as an extra 'sanity check' layer in `spec/integration/db`. Please don't create them as an excuse to not write solid unit tests.

Please do add them if they seem like a good idea! If you add one and it fails, please write a corresponding failing unit spec before fixing up.


## Working with Changes

### Running against local source

Load a console with `cassie` source loaded to work with Cassie directly in development.

```
bin/console
```
```
irb(main):001:0> Cassie::VERSION
=> "1.0.0.beta.30-dev"
```

Run the executable with local source:

```
bin/run schema:version
```
```
+-----------+-------------+-------------+---------------------------+
| Number    | Description | Migrated by | Migrated at               |
+-----------+-------------+-------------+---------------------------+
| * 0.2.0.0 | test        | eprothro    | 2017-02-02 16:21:39 -0600 |
+-----------+-------------+-------------+---------------------------+
```

### Installing your changes locally

Run `rake install` to:
* Run the test suite (Cassandra NOT required)
* Build the gem
* Install into your local gemset

Or you may want to reference your changes from another project:
* Add `gem "cassie", path: 'YOUR-SOURCE-DIRECTORY/cassie'` to your other project's `Gemfile`
* Run `bundle`
* Execution will now use the source files in `YOUR-SOURCE-DIRECTORY/cassie`
* Changes are included automatically (by definition)

### Releasing (maintainers only)

Run `rake release` to:
* Run the full test suite (Cassandra running locally requried)
* Build the gem
* Publish the gem
* Bump the version (patch)

### Bumping the version

Bump version minor / major with `gem bump --version <minor|major>`.

Please don't include version bumps in your patches. Maintainers will handle this.
