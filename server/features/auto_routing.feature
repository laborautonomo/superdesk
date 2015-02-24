Feature: Auto Routing

    @auth @provider
    Scenario: Content is fetched based on subject metadata
        Given empty "desks"
        When we post to "/desks"
        """
          {
            "name": "Sports Desk", "members": [{"user": "#CONTEXT_USER_ID#"}]
          }
        """
        Then we get response code 201
        When we post to "/routing_schemes"
        """
        [
          {
            "name": "routing rule scheme 1",
            "rules": [
              {
                "name": "Sports Rule",
                "filter": {
                  "subject": [{"qcode": "15000000"}]
                },
                "actions": {
                  "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}],
                  "exit": false
                }
              }
            ]
          }
        ]
        """
        Then we get response code 201
        When we post to "/desks"
        """
          {
            "name": "Finance Desk", "members": [{"user": "#CONTEXT_USER_ID#"}]
          }
        """
        Then we get response code 201
        When we patch routing scheme "/routing_schemes/#routing_schemes._id#"
        """
           {
              "name": "Finance Rule",
              "filter": {
                "subject": [{"qcode": "04000000"}]
              },
              "actions": {
                "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}],
                "exit": false
              }
           }
        """
        Then we get response code 200
        When we fetch from "AAP" ingest "aap-finance.xml" using routing_scheme
        """
        #routing_schemes._id#
        """
        Then the ingest item is routed based on routing scheme and rule "Finance Rule"
        """
        {
          "routing_scheme": "#routing_schemes._id#",
          "ingest": "AFP.121974877.6504909"
        }
        """
        Then the ingest item is not routed based on routing scheme and rule "Sports Rule"
        """
        {
          "routing_scheme": "#routing_schemes._id#",
          "ingest": "AFP.121974877.6504909"
        }
        """
        When we fetch from "AAP" ingest "aap-sports.xml" using routing_scheme
        """
        #routing_schemes._id#
        """
        Then the ingest item is routed based on routing scheme and rule "Sports Rule"
        """
        {
          "routing_scheme": "#routing_schemes._id#",
          "ingest": "AAP.123253116.6697929"
        }
        """
        Then the ingest item is not routed based on routing scheme and rule "Finance Rule"
        """
        {
          "routing_scheme": "#routing_schemes._id#",
          "ingest": "AAP.123253116.6697929"
        }
        """

    @auth @provider @test
    Scenario: Package is routed automatically
        Given empty "desks"
        When we post to "/desks"
        """
          {
            "name": "World Desk", "members": [{"user": "#CONTEXT_USER_ID#"}]
          }
        """
        Then we get response code 201
        When we post to "/routing_schemes"
        """
        [
          {
            "name": "routing rule scheme 1",
            "rules": [
              {
                "name": "Syria Rule",
                "filter": {
                  "slugline": "syria"
                },
                "actions": {
                  "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}],
                  "exit": false
                }
              }
            ]
          }
        ]
        """
        Then we get response code 201
        When we fetch from "reuters" ingest "tag_reuters.com_2014_newsml_KBN0FL0NM" using routing_scheme
        """
        #routing_schemes._id#
        """
        Then the ingest item is routed based on routing scheme and rule "Syria Rule"
        """
        {
          "routing_scheme": "#routing_schemes._id#",
          "ingest": "tag_reuters.com_2014_newsml_KBN0FL0NM"
        }
        """

    @auth @provider
    Scenario: Content is fetched and published to different stages
        Given empty "desks"
        When we post to "/desks"
        """
          {
            "name": "Finance Desk", "members": [{"user": "#CONTEXT_USER_ID#"}]
          }
        """
        Then we get response code 201
        When we post to "/routing_schemes"
        """
        [
          {
            "name": "routing rule scheme 1",
            "rules": [
              {
                "name": "Finance Rule 1",
                "filter": {
                  "subject": [{"qcode": "04000000"}]
                },
                "actions": {
                  "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}],
                  "exit": false
                }
              }
            ]
          }
        ]
        """
        Then we get response code 201
        When we post to "/stages"
        """
        [
          {
            "name": "Published",
            "description": "Published Content",
            "task_status": "in_progress",
            "desk": "#desks._id#"
          }
        ]
        """
        Then we get "_id"
        When we post to "/stages"
        """
        [
          {
            "name": "Un Publsihed",
            "description": "Published Content",
            "task_status": "in_progress",
            "desk": "#desks._id#"
          }
        ]
        """
        When we patch routing scheme "/routing_schemes/#routing_schemes._id#"
        """
           {
              "name": "Finance Rule 2",
              "filter": {
                "subject": [{"qcode": "04000000"}, {"qcode": "04019000"}]
              },
              "actions": {
                "fetch": [{"desk": "#desks._id#", "stage": "#_id#"}],
                "publish": [{"desk": "#desks._id#", "stage": "#stages._id#"}],
                "exit": false
              }
           }
        """
        Then we get response code 200
        When we fetch from "AAP" ingest "aap-finance.xml" using routing_scheme
        """
        #routing_schemes._id#
        """
        Then the ingest item is routed based on routing scheme and rule "Finance Rule 1"
        """
        {
          "routing_scheme": "#routing_schemes._id#",
          "ingest": "AFP.121974877.6504909"
        }
        """
        Then the ingest item is routed based on routing scheme and rule "Finance Rule 2"
        """
        {
          "routing_scheme": "#routing_schemes._id#",
          "ingest": "AFP.121974877.6504909"
        }
        """
        When we fetch from "AAP" ingest "aap-finance1.xml" using routing_scheme
        """
        #routing_schemes._id#
        """
        Then the ingest item is routed based on routing scheme and rule "Finance Rule 2"
        """
        {
          "routing_scheme": "#routing_schemes._id#",
          "ingest": "AAP.0.6703189"
        }
        """
        Then the ingest item is routed based on routing scheme and rule "Finance Rule 1"
        """
        {
          "routing_scheme": "#routing_schemes._id#",
          "ingest": "AAP.0.6703189"
        }
        """

    @auth @provider
    Scenario: Content is fetched and published to different stages
        Given empty "desks"
        When we post to "/desks"
        """
          {
            "name": "Finance Desk", "members": [{"user": "#CONTEXT_USER_ID#"}]
          }
        """
        Then we get response code 201
        When we post to "/routing_schemes"
        """
        [
          {
            "name": "routing rule scheme 1",
            "rules": [
              {
                "name": "Finance Rule 1",
                "filter": {
                  "subject": [{"qcode": "04000000"}]
                },
                "actions": {
                  "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}],
                  "exit": false
                }
              }
            ]
          }
        ]
        """
        Then we get response code 201
        When we post to "/stages"
        """
        [
          {
            "name": "Published",
            "description": "Published Content",
            "task_status": "in_progress",
            "desk": "#desks._id#"
          }
        ]
        """
        When we patch routing scheme "/routing_schemes/#routing_schemes._id#"
        """
           {
              "name": "Finance Rule 2",
              "filter": {
                "subject": [{"qcode": "04000000"}]
              },
              "actions": {
                "fetch": [{"desk": "#desks._id#", "stage": "#stages._id#"}],
                "exit": false
              }
           }
        """
        Then we get response code 200
        When we schedule the routing scheme "#routing_schemes._id#"
        When we fetch from "AAP" ingest "aap-finance.xml" using routing_scheme
        """
        #routing_schemes._id#
        """
        Then the ingest item is not routed based on routing scheme and rule "Finance Rule 1"
        """
        {
          "routing_scheme": "#routing_schemes._id#",
          "ingest": "AFP.121974877.6504909"
        }
        """
        Then the ingest item is routed based on routing scheme and rule "Finance Rule 2"
        """
        {
          "routing_scheme": "#routing_schemes._id#",
          "ingest": "AFP.121974877.6504909"
        }
        """