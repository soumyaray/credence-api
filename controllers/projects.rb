# frozen_string_literal: true

require 'roda'

module Credence
  # Web controller for Credence API
  class Api < Roda
    route('projects') do |routing|
      @proj_route = "#{@api_root}/projects"

      routing.on String do |proj_id|
        # GET api/v1/projects/[proj_id]
        routing.get do
          account = Account.first(username: @auth_account['username'])
          project = Project.first(id: proj_id)
          policy  = ProjectPolicy.new(account, project)
          raise unless policy.can_view?

          project.full_details
                 .merge(policies: policy.summary)
                 .to_json
        rescue StandardError
          routing.halt 404, { message: 'Project not found' }.to_json
        end

        routing.on('documents') do
          # POST api/v1/projects/[proj_id]/documents
          routing.post do
            account = Account.first(username: @auth_account['username'])
            project = Project.first(id: proj_id)
            doc_data = JSON.parse(routing.body.read)

            requestor = ProjectPolicy.new(account, project)
            raise unless requestor.can_add_documents?

            new_document = project.add_document(doc_data)
            response.status = 201
            new_document.to_json
          rescue StandardError => error
            puts error.inspect
            puts error.backtrace
            routing.halt 400, { message: 'Could not add document' }.to_json
          end
        end

        routing.on('collaborators') do # rubocop:disable Metrics/BlockLength
          # PUT api/v1/projects/[proj_id]/collaborators
          routing.put do
            account = Account.first(username: @auth_account['username'])
            project = Project.first(id: proj_id)
            req_data = JSON.parse(routing.body.read)
            collaborator = Account.first(email: req_data['email'])

            requestor = ProjectPolicy.new(account, project)
            outsider = ProjectPolicy.new(collaborator, project)

            raise unless requestor.can_add_collaborators? &&
                         outsider.can_collaborate?

            project.add_collaborator(collaborator)
            collaborator.to_json
          rescue StandardError
            routing.halt 400, { message: 'Could not add collaborator' }.to_json
          end

          # DELETE api/v1/projects/[proj_id]/collaborators
          routing.delete do
            account = Account.first(username: @auth_account['username'])
            project = Project.first(id: proj_id)
            req_data = JSON.parse(routing.body.read)
            collaborator = Account.first(email: req_data['email'])

            requestor = ProjectPolicy.new(account, project)

            raise unless requestor.can_remove_collaborators? &&
                         project.collaborators.include?(collaborator)

            project.remove_collaborator(collaborator)
            collaborator.to_json
          rescue StandardError => error
            puts error.inspect
            puts error.backtrace
            routing.halt 400, { message: 'Could not remove collaborator' }.to_json
          end
        end
      end

      # GET api/v1/projects
      routing.get do
        account = Account.first(username: @auth_account['username'])
        projects_scope = ProjectPolicy::AccountScope.new(account)
        viewable_projects = projects_scope.viewable

        JSON.pretty_generate(viewable_projects)
      rescue StandardError
        routing.halt 403, { message: 'Could not find projects' }.to_json
      end

      # POST api/v1/projects
      routing.post do
        account = Account.first(username: @auth_account['username'])
        new_data = JSON.parse(routing.body.read)
        new_proj = account.add_owned_project(new_data)

        response.status = 201
        response['Location'] = "#{@proj_route}/#{new_proj.id}"
        { message: 'Project saved', data: new_proj }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => error
        routing.halt 500, { message: error.message }.to_json
      end
    end
  end
end
