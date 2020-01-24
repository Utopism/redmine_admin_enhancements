namespace :smile do
  namespace :tools do
    namespace :tree do
      desc 'Repair ciruclar references of issues (params : root_id, dry_run)'
      task :repair_circular_references => :environment do
        root_id = nil
        root_id = ENV['root_id'] if ENV['root_id'].present?
        Issue.rebuild! false, root_id, ENV['dry_run']
      end

      desc "Get issue's children (params : issue_id, sort)"
      task :issue_children => :environment do
        abort "issue_id parameter not specified." if ENV['issue_id'].blank?

        i = Issue.find_by_id ENV['issue_id']

        abort "Issue ##{ENV['issue_id']} not found !!!" if i.nil?

        sort = ENV['sort'].present?

        puts "Children and relations of ##{i.id} :"

        ichild = i.children
        ichild = ichild.sort! {|x,y| x.id <=> y.id } if sort

        trace = ''
        ichild.each_with_index{ |c, i|
          trace += "#{i}) #{c.id}#{ c.valid? ? '' : ' INVALID' }\n"

          children2 = c.children
          if children2.any?
            children2 = children2.sort! {|x,y| x.id <=> y.id } if sort
            trace += "    ---> #{ children2.collect{|c2| "#{c2.id}#{ c2.valid? ? '' : ' INVALID' }"}.join(', ') }\n"
          end

          trace += "    rels " +
            c.relations.collect{ |r|
              "#{ r.issue_from_id if (r.issue_from_id != c.id) }#{ r.issue_to_id if (r.issue_to_id != c.id) }"
            }.join(', ') + "\n" if c.relations.any?

          nil
        }

        puts trace
      end

      desc 'Detect wrong root_id compared to parent_id'
      task :detect_wrong_root => :environment do
        children = Issue.where("parent_id IS NOT NULL").includes([:project, :parent]).to_a

        puts "- [#{children.size}] children issue(s) found  -- #{Time.now.to_s(:db)}"

        issues_to_fix = []
        root_issues_to_fix = []
        i = 0
        children.each{ |c|
          puts "##{c.id}  -- #{Time.now.to_s(:db)}"

          parent = c.parent
          if parent.nil?
            puts "  ERROR : #{c.id} #{c.project.identifier} parent #{c.parent_id} NOT found!\n"
            next
          end

          if parent.root_id != c.root_id
            puts "  INFO : #{i}) #{c.id} #{c.project.identifier} parent_id=#{c.parent_id} root_id=#{c.root_id} should be #{parent.root_id}\n"
            i += 1
            issues_to_fix << [c.id, parent.root_id]
            root_issues_to_fix << parent.root_id if ! root_issues_to_fix.include?(parent.root_id)
          end
        }

        puts ""

        if root_issues_to_fix.empty?
          puts "Everything OK :-)"
        else
          puts "Issues to FIX :"

          issues_to_fix.each{ |f|
            puts "UPDATE issues SET root_id='#{f[1]}' WHERE id='#{f[0]}';\n"
          }

         puts "\nroot issues to recalculate lft and rgt (with ruby console):\n"
          root_issues_to_fix.each{ |r|
            puts "Issue.rebuild_single_tree!(#{r})\n"
          }
        end

        nil
      end
    end
  end
end
