# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, projects, documents'
    create_accounts
    create_projects
    create_documents
    add_collaborators
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ALL_ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
ALL_PROJ_INFO = YAML.load_file("#{DIR}/projects_seed.yml")
ALL_DOCUMENT_INFO = YAML.load_file("#{DIR}/documents_seed.yml")
ALL_CONTRIB_INFO = YAML.load_file("#{DIR}/collaborators_seed.yml")

def create_accounts
  ALL_ACCOUNTS_INFO.each do |account_info|
    Credence::Account.create(account_info)
  end
end

def create_projects
  proj_info_each = ALL_PROJ_INFO.each
  accounts_cycle = Credence::Account.all.cycle
  loop do
    proj_info = proj_info_each.next
    account = accounts_cycle.next
    Credence::CreateProjectForOwner.call(owner_id: account.id, project_data: proj_info)
  end
end

def create_documents
  doc_info_each = ALL_DOCUMENT_INFO.each
  projects_cycle = Credence::Project.all.cycle
  loop do
    doc_info = doc_info_each.next
    project = projects_cycle.next
    Credence::CreateDocumentForProject.call(
      project_id: project.id, document_data: doc_info
    )
  end
end

def add_collaborators
  contrib_info = ALL_CONTRIB_INFO
  contrib_info.each do |contrib|
    proj = Credence::Project.first(name: contrib['proj_name'])
    contrib['collaborator_email'].each do |email|
      collaborator = Credence::Account.first(email: email)
      proj.add_collaborator(collaborator)
    end
  end
end
