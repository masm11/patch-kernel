#!/usr/bin/env ruby
# coding: utf-8

@srcdir = 'linux-4'
@patchdir = 'patch'

version = 0
patchlevel = 0
sublevel = 0
File::open("#{@srcdir}/Makefile") { |f|
  f.each_line { |line|
    line.chomp!
    if /^VERSION\s*=\s*(\d+)$/ =~ line
      version = $1.to_i
    elsif /^PATCHLEVEL\s*=\s*(\d+)$/ =~ line
      patchlevel = $1.to_i
    elsif /^SUBLEVEL\s*=\s*(\d+)$/ =~ line
      sublevel = $1.to_i
    end
  }
}

def patch_fname(v, p, s)
  if s == 0
    return "patch-#{v}.#{p}.xz"
  else
    return "patch-#{v}.#{p}.#{s}.xz"
  end
end

def patch_exist?(v, p, s)
  r = File.exist?("#{@patchdir}/#{patch_fname(v, p, s)}")
  return r
end

def patch_apply(v, p, s, rev)
  r = rev ? '-R' : ''
  print "Applying #{r} #{patch_fname(v, p, s)}\n"
  system("cd #{@srcdir} && xzcat ../#{@patchdir}/#{patch_fname(v, p, s)} | patch -p1 #{r}")
  if $? != 0
    STDERR.print "failed...\n"
    exit 1
  end
end

# 次の patchlevel へ行けるだけ行く。
# 行くためには patch-v.p.s.xz(s!=0の場合) と patch-v.p+1.0.xz が必要。
while (sublevel == 0 || patch_exist?(version, patchlevel, sublevel)) &&
   patch_exist?(version, patchlevel + 1, 0)
  if sublevel > 0
    patch_apply(version, patchlevel, sublevel, true)
    sublevel = 0
  end
  
  patch_apply(version, patchlevel + 1, 0, false)
  patchlevel += 1
end

# 最大の sublevel へ jump。
if patch_exist?(version, patchlevel, sublevel)
  sub = sublevel
  Dir.glob("#{@patchdir}/patch-#{version}.#{patchlevel}.*.xz") { |fn|
    if /patch-\d+\.\d+\.(\d+)\.xz/ =~ fn
      s = $1.to_i
      if s > sub
        sub = s
      end
    end
  }
  
  if sublevel != sub
    if sublevel != 0
      patch_apply(version, patchlevel, sublevel, true)
      sublevel = 0
    end
    
    patch_apply(version, patchlevel, sub, false)
    sublevel = sub
  end
end

print "Now, #{version}.#{patchlevel}.#{sublevel}.\n"
exit 0
