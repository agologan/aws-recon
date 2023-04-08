# frozen_string_literal: true

#
# Collect SQS resources
#
class SQS < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_queues
    #
    @client.list_queues.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.queue_urls.each do |queue|
        log(response.context.operation_name, queue.downcase.split('/').last, page)

        # get_queue_attributes
        struct = OpenStruct.new(@client.get_queue_attributes({ queue_url: queue, attribute_names: ['All'] }).attributes.to_h)
        struct.type = 'queue'
        struct.arn = struct.QueueArn
        struct.policy = struct.Policy ? struct.delete_field('Policy').parse_policy : nil
        struct.tags = @client.list_queue_tags({ queue_url: queue }).tags

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
