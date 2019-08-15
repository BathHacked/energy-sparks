[![Build Status](https://travis-ci.org/BathHacked/energy-sparks.svg?branch=master)](https://travis-ci.org/BathHacked/energy-sparks)
[![Maintainability](https://api.codeclimate.com/v1/badges/1d4f9219bfa9e5848154/maintainability)](https://codeclimate.com/github/BathHacked/energy-sparks/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/1d4f9219bfa9e5848154/test_coverage)](https://codeclimate.com/github/BathHacked/energy-sparks/test_coverage)



# Energy Sparks

Energy Sparks is an open source application that is designed to help schools improve their energy efficiency.

The application collects and presents gas and electricity usage data in a way that is accessible to staff, students and parents. Supported by educational resources, the application will support teachers in helping children understand more about energy usage, how to be more efficient and see how actions they take in the school, e.g. switching off lighting, has an effect on usage.

Combining access to data, the ability to log interventions and a competitive element between schools, the goal is to not just save schools money in reducing energy consumption through long term changes, it is hoped that the application will also help educate children about what it means to be energy efficient.

The application is open source and is powered by open data. It is being designed to be easily deploy and run for minimal cost, allowing it to be run by local councils and/or community groups around the UK.

The initial prototype application and user testing is being carried out in Bath & North East Somerset. The work is a joint project between Bath: Hacked, Transition Bath, Resource Futures and B&NES council.

The project has been funded by an award from the Open Data Institute summer showcase 2016.

# For Users

Development of the application and documentation is in progress. Please check back later for more information.

For now you may wish to read the evolving documentation in [the project wiki](https://github.com/BathHacked/energy-sparks/wiki).

# For Developers

The application is a Rails 6, Ruby 2.5.3 project.

Read the CONTRIBUTING.md guidelines for how to get started.

## Extra notes

Development mode uses mail catcher for sending mails - you need to install the [mailcatcher gem](https://github.com/sj26/mailcatcher) for this to work correctly.

## Refreshing test db

1) Get DB dump from production
2) Search and replace the production user with the test user in the sql file
3) On test, drop all tables, schema
4) Run psql against test database and import database

```
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

You may also need to restore the default grants.

GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
```
5) Nobble email users on test
```
bundle exec rake utility:prepare_test_server
```

# Creating a new environment on Elastic Beanstalk

* Using the actions drop down, click Create Environment
* Choose Web server environment and click Continue
* Choose an environment name, normally we are using the AWS linux platform version, along with test or prod, i.e. prod-2-10-1 or test-2-8-7
* Choose preconfigured platform of Ruby
* Leave the application code setting as the Sample Application
* Click 'Configure More Options' and set up:

### Capacity:

* Change environment to load balanced (1-1)

### Load Balancer:

* Choose a Classic load balancer

### Instances:

* Set instance to t2.small

### Security:

* Add previously created key in security [IAM DevOps](https://eu-west-2.console.aws.amazon.com/ec2/v2/home?region=eu-west-2#KeyPairs:sort=keyName) (i.e. EnergySparksProductionEC2Machine or EnergySparksTestEC2)

### Software

Leave this for now, we will add the environment variables once the environment has been created with the sample app

## Create environment

Click the Create environment button

### Once environment has been created

  * Set environment variables

    get existing ones from an existing environment by running ```eb printenv``` and then set them on the new environment (easiest to have a branch which is configured as a default to use new environment using ```.elasticbeanstalk/config.yml```) using ```eb setenv THIS_VAR=x THAT_VAR=y``` etc
    
    You will need to:
     * split the output from printenv in two and
     * remove the spaces which surround the = signs
     * take out AWS_ACCESS_KEY_ID as it will not process correctly
     
  * Check environment variables through web console and add AWS_ACCESS_KEY_ID back in again
  * Click apply
  
  * Check SSH works to new environment with ```eb ssh``` 
  * Then deploy actual branch
  
  * Set up DNS in Route 53 if creating a brand new environment
  * Set up cert and get it to create DNS record if you didn't do this already or are not using an existing one

  * Add Listener to Load Balancer -
      Listener Port 443
      Listener Protocol HTTPS
      Instance Port 80
      Instance Protocol HTTP

    and add certificate once it has been validated
    
   * If you are running this environment in parallel with an existing one, make sure you:
     * set the APPLICATION_HOST to what you want it to be
     * stop the CRON jobs running if you are sharing a database on one of the environments
     * Note that the CDN will complain because of CORS unless you create a distribution for that.
    
## Sort out Database config

### For existing database:

Get the RDS launch wizard group and add access INBOUND for the AWSEBSecurityGroup created by EB for the new instance

### For new database:

1) Set up appropriate database in RDS - make sure the password doesn't have any (or too many) special characters, best to keep to digits and letters if possible!
2) Use pg_dump to get dump of current production database
3) Use psql to get data into new database

