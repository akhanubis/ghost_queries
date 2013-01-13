#encoding: UTF-8

module GCFinder
  class Acl
    class << self
      def create!(authorization, calendar_id, rule)
        GCFinder.api_client.execute(
          api_method: GCFinder.google_calendar.acl.insert,
          parameters: {'calendarId' => calendar_id},
          body: JSON.dump(rule),
          headers: {'Content-Type' => 'application/json'},
          authorization: authorization)
      end

      def update!(authorization, calendar_id, rule_id, role)
        GCFinder.api_client.execute(
          api_method: GCFinder.google_calendar.acl.update,
          parameters: {'calendarId' => calendar_id, 'rule_id' => rule_id},
          body_object: role,
          authorization: authorization)
      end

      def create_reader(authorization, calendar_id, google_user)
        rule = {
            'scope' => {
                'type' => 'user',
                'value' => google_user,
            },
            'role' => 'reader'
        }
        create!(authorization, calendar_id, rule)
      end

      def create_writer(authorization, calendar_id, google_user)
        rule = {
            'scope' => {
                'type' => 'user',
                'value' => google_user,
            },
            'role' => 'writer'
        }
        create!(authorization, calendar_id, rule)
      end
    end
  end
end