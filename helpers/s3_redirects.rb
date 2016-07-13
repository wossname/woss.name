module Middleman
  module Sitemap
    module Extensions
      class RedirectResource
        def initialize(store, path, target)
          super(store, path)

          @request_path = target
        end

        def target_url
          @target_url ||= ::Middleman::Util.url_for(@store.app, @request_path, relative: false, find_resource: true)
        end
      end
    end
  end

  module S3Sync
    class Resource
      REDIRECT_KEY = 'x-amz-website-redirect-location'

      def to_h
        attributes = {
          :key => key,
          :acl => options.acl,
          :content_type => content_type,
          CONTENT_MD5_KEY => local_content_md5
        }

        if caching_policy
          attributes[:cache_control] = caching_policy.cache_control
          attributes[:expires] = caching_policy.expires
        end

        if options.prefer_gzip && gzipped
          attributes[:content_encoding] = "gzip"
        end

        if options.reduced_redundancy_storage
          attributes[:storage_class] = 'REDUCED_REDUNDANCY'
        end

        if options.encryption
          attributes[:encryption] = 'AES256'
        end

        if redirect?
          attributes[REDIRECT_KEY] = redirect_url
        end

        attributes
      end

      def status
        @status ||= if directory?
                      if remote?
                        :deleted
                      else
                        :ignored
                      end
                    elsif local? && remote?
                      if options.force
                        :updated
                      elsif not metadata_match?
                        :updated
                      elsif local_object_md5 == remote_object_md5
                        :identical
                      else
                        if !gzipped
                          # we're not gzipped, object hashes being different indicates updated content
                          :updated
                        elsif !encoding_match? || local_content_md5 != remote_content_md5
                          # we're gzipped, so we checked the content MD5, and it also changed
                          :updated
                        else
                          # we're gzipped, the object hashes differ, but the content hashes are equal
                          # this means the gzipped bits changed while the original bits did not
                          # what's more, we spent a HEAD request to find out
                          :alternate_encoding
                        end
                      end
                    elsif local?
                      :new
                    elsif remote? && redirect?
                      :ignored
                    elsif remote?
                      :deleted
                    else
                      :ignored
                    end
      end

      def redirect?
        (!resource.nil? && resource.is_a?(Middleman::Sitemap::Extensions::RedirectResource)) ||
          (full_s3_resource && full_s3_resource.metadata.has_key?(REDIRECT_KEY))
      end

      def metadata_match?
        redirect_match? && caching_policy_match?
      end

      def redirect_match?
        if redirect?
          redirect_url == remote_redirect_url
        else
          true
        end
      end

      def remote_redirect_url
        full_s3_resource.metadata[REDIRECT_KEY]
      end

      def redirect_url
        resource.target_url
      end
    end
  end
end
