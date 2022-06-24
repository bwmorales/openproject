#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2022 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

# This class provides definitions for API routes and endpoints for the file_links namespace. It inherits the
# functionality from the Grape REST API framework. It is mounted in lib/api/v3/work_packages/work_packages_api.rb,
# which puts the file_links namespace behind the provided namespace of the work packages api
# -> /api/v3/work_packages/:id/file_links/...
module API
  module V3
    module FileLinks
      class WorkPackagesFileLinksAPI < ::API::OpenProjectAPI
        # helpers is defined by the grape framework. They make methods from the
        # module available from within the endpoint context.
        helpers API::V3::Utilities::StoragesHelpers

        before do
          reply_with_not_found_if_module_inactive
        end

        # ToDo: Check race condition if two users try to get the same WP file_links?

        # The `:resources` keyword defines the API namespace -> /api/v3/work_packages/:id/file_links/...
        resources :file_links do
          # Get the list of FileLinks related to a work package.
          # First we synchronize the list of file links between
          # the OAuth2 Server and the database, then we just return
          # the database contents.
          get do
            # Get the list of all FileLinks for the work package.
            # This could be a huge array in some cases...
            file_links = visible_file_links_scope.where(container_id: @work_package.id).all
            # ToDo: Filter on container_type = "WorkPackage"

            # Start a synchronization process to get updated file metadata from Nextcloud.
            # We assume that a valid OAuthClientToken is available for the current user.
            # This is ensured by StorageAPI/StorageRepresenter which handle the case
            # of a missing authorization.
            # Error handling: FileLinkSyncService returns the entire list with :shared_with_me = false
            # so all files will appear, but non is accessible to the user.
            service_result = ::Storages::FileLinkSyncService
                               .new(user: current_user, file_links:)
                               .call

            # Check service_result.success
            result_file_links = service_result.result

            # Convert to JSON
            ::API::V3::FileLinks::FileLinkCollectionRepresenter.new(
              result_file_links,
              self_link: api_v3_paths.work_package_file_links(@work_package.id),
              current_user:
            )
          end

          post &CreateEndpoint
                  .new(
                    model: ::Storages::FileLink,
                    parse_service: ParseCreateParamsService,
                    render_representer: FileLinkCollectionRepresenter
                  )
                  .mount
        end
      end
    end
  end
end
