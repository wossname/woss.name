---
published_on: 2006-10-25
title: Migrating your Rails application to Unicode
redirect_from:
  - "/2006/10/25/migrating-your-rails-application-to-unicode/"
  - "/blog/2006/10/25/migrating-your-rails-application-to-unicode.html"
category: Programming
tags:
  - unicode
  - ruby
  - rails
  - mysql
  - utf8
---
**Update** Make sure you read the comments on this post before considering it.  In particular, [Pete](/2006/10/25/migrating-your-rails-application-to-unicode/#comment-13156) brings up some concerns about applications having data which is already UTF-8, but marked as Latin1 in the database, may cause problems.

So you've got this Rails application you've been developing and all of a sudden
you need to support Unicode. After all, not everybody speaks English. And some
really awkward people like all sorts of typographic symbols in their medical
articles. In fact, you wouldn't believe all the weird characters these
print-production-oriented people like to use&hellip;

Most of the instructions here were gleamed from a [jabbering giraffe](http://happygiraffe.net/blog/archives/2006/09/16/unicode-for-rails) and the [notes I wrote up from his talk](/2006/10/11/railsconf-europe-2006-unicode-for-rails-dominic-mitchell/).  But I like to think I've had a bright idea of my own. :-)  Note that these instructions assume you're using Ruby 1.8.x, MySQL >= 5 and edge (soon to be 1.2) rails.

OK, so to get Rails basically talking UTF-8, you have to do a couple of things.
Firstly, make Ruby itself a little bit Unicode-aware, by sticking the following
in `config/environment.rb`:

    $KCODE = 'u'

We also need to tell ActiveRecord that the connection it should open to MySQL
should be UTF-8 encoded. This is done by putting the following in each of your
database stanzas in `config/database.yml`:

    encoding: utf8

Finally, from a setup perspective, we need to migrate the current database to
one which uses UTF-8 encoding internally. This is what I consider to be my
'smart' bit. :-) Create yourself a migration:

    script/generate migration make_unicode_friendly

then paste in the following code:

```ruby
class MakeUnicodeFriendly < ActiveRecord::Migration
  def self.up
    alter_database_and_tables_charsets "utf8", "utf8_general_ci"
  end

  def self.down
    alter_database_and_tables_charsets
  end

  private
  def self.alter_database_and_tables_charsets charset = default_charset, collation = default_collation
    case connection.adapter_name
    when 'MySQL'
      execute "ALTER DATABASE #{connection.current_database} CHARACTER SET #{charset} COLLATE #{collation}"

      connection.tables.each do |table|
        execute "ALTER TABLE #{table} CONVERT TO CHARACTER SET #{charset} COLLATE #{collation}"
      end
    else
      # OK, not quite irreversible but can't be done if there's not
      # the code here to support it...
      raise ActiveRecord::IrreversibleMigration.new("Migration error: Unsupported database for migration to UTF-8 support")
    end
  end

  def self.default_charset
    case connection.adapter_name
    when 'MySQL'
      execute("show variables like 'character_set_server'").fetch_hash['Value']
    else
      nil
    end
  end

  def self.default_collation
    case connection.adapter_name
    when 'MySQL'
      execute("show variables like 'collation_server'").fetch_hash['Value']
    else
      nil
    end
  end

  def self.connection
    ActiveRecord::Base.connection
  end
end
```

This migrates the current database to using UTF-8 with general,
case-insensitive collation, which affects the creation of future tables. It
also updates each of the current tables, converting their contents to UTF-8 too.

And it's reversible. Well, mostly. It makes the assumption that the previous
character set you were using was the server's default (which, unless you
explicitly specified a character set/collation upon creation will be the case),
and reverts back to that. Of course, a backward migration may well be lossy, so
you want to be careful trying that.

The next bit is the tricky one. Most of the Ruby string functions aren't
Unicode-aware. They'll quite happily `slice` up multi-byte characters.
Fortunately edge rails now extends `String` to provide a `chars` method which
returns an
[`ActiveSupport::Multibyte::Chars`](http://multibyterails.org/documentation/activesupport_multibyte/classes/ActiveSupport/Multibyte/Chars.html) object. It
walks like a string and talks like a string, but is multibyte aware. Nice.
Apparently there's active work going on in the core to get internal Rails stuff
to use this new functionality, so hopefully it should be pretty good soon.

Hopefully it should be good enough for me to use just now...
