Feature: Setting up server/key configurations in a config file
  In order to easily manage which keys should be deployed to which server
  As a whatever i have no idea srsly
  I want to write a config file which gets parsed correctly to a working server/serverpool/key setup

  Scenario: a config file with groups, servers and roles
    Given the server "13.9.6.1"
    And the server "13.9.6.2"
    And the server "13.9.6.3"
    And the local keyfiles
      | name | key                      |
      | key1 | ssh-rsa key1== foobar    |
      | key2 | ssh-rsa key2== something |
      | key3 | ssh-rsa key3== snafu     |
      | key4 | ssh-dsa key4== bazz      |
    And the config
    """
    [group devs]
      members = key1, key2, key3

    [role app]
      servers = 13.9.6.1, 13.9.6.2
      keys = &devs, key4
    
    [server 13.9.6.3]
      keys = key2
    """
    When I parse the config and run the upload_keys command
    Then the following keys should be on the servers
      | server     | key                      |
      | 13.9.6.1  | ssh-rsa key1== foobar    |
      | 13.9.6.1  | ssh-rsa key2== something |
      | 13.9.6.1  | ssh-rsa key3== snafu     |
      | 13.9.6.1  | ssh-dsa key4== bazz      |
      | 13.9.6.2  | ssh-rsa key1== foobar    |
      | 13.9.6.2  | ssh-rsa key2== something |
      | 13.9.6.2  | ssh-rsa key3== snafu     |
      | 13.9.6.2  | ssh-dsa key4== bazz      |
      | 13.9.6.3  | ssh-rsa key2== something |

    Scenario: creating a new config file from a serverpool
      Given the following hosts
        """
          13.9.1.41      preview_server
          13.9.1.42      edge_server
          10.53.1.41      production_server
        """
      And the following keys are on the servers
        | server     | key                                                   |
        | 13.9.1.41 | ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO            |
        | 13.9.1.41 | ssh-rsa key4== abel.fernandez@nb-afernandez.local     |
        | 13.9.1.41 | ssh-dss key2== christian.kvalheim@nb-ckvalheim.local  |
        | 13.9.1.42 | ssh-rsa key3== lee.hambley@xing.com                   |
        | 10.53.1.41 | ssh-rsa key5== pascal.friederich@nb-pfriederich.local |
      When I build the config from scratch
      Then I should have the following config
        """
        [server 13.9.1.41]
          keys = adem_deliceoglu, abel_fernandez, christian_kvalheim
        
        [server 13.9.1.42]
          keys = lee_hambley
      
        [server 10.53.1.41]
          keys = pascal_friederich
        
        """
