scaffold_policy_name="base"
pkg_name=chef-linux-hardening-demo
pkg_origin=jvdemo
pkg_version="0.1.0"
pkg_svc_user=("root")

pkg_deps=(
  "chef/chef-client"
  "core/cacerts"
  "core/sed"
)
pkg_build_deps=(
  "chef/chef-dk"
  "core/git"
)

do_default_build() {
  if [ -d "$PLAN_CONTEXT/../policyfiles" ]; then
    _policyfile_path="$PLAN_CONTEXT/../policyfiles"
  else
    if [ -d "$PLAN_CONTEXT/../../policyfiles" ]; then
      _policyfile_path="$PLAN_CONTEXT/../../policyfiles"
    else
      if [ -d "$PLAN_CONTEXT/../../../policyfiles" ]; then
        _policyfile_path="$PLAN_CONTEXT/../../../policyfiles"
      else
        echo "Cannot detect a policyfiles directory!"
        exit 1
      fi
    fi
  fi
  rm -f "$_policyfile_path"/*.lock.json
  policyfile="$_policyfile_path/$scaffold_policy_name.rb"
  for x in $(grep include_policy "$policyfile" | awk -F "," '{print $1}' | awk -F '"' '{print $2}' | tr -d " "); do
    chef install "$_policyfile_path/$x.rb"
  done
  chef install "$policyfile"
}

do_default_install() {
  chef export "$_policyfile_path/$scaffold_policy_name.lock.json" "$pkg_prefix"

  mkdir -p "$pkg_prefix/config"
  chmod 0750 "$pkg_prefix/config"
  mkdir -p "$pkg_prefix/.chef"
  chmod 0750 "$pkg_prefix/.chef"
  cat << EOF >> "$pkg_prefix/.chef/config.rb"
cache_path "$pkg_svc_data_path/cache"
node_path "$pkg_svc_data_path/nodes"
role_path "$pkg_svc_data_path/roles"
chef_zero.enabled true
EOF

  cp "$pkg_prefix/.chef/config.rb" "$pkg_prefix/config/bootstrap-config.rb"
  cat << EOF >> "$pkg_prefix/config/bootstrap-config.rb"
ENV['PATH'] = "/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:#{ENV['PATH']}"
EOF

  cp "$pkg_prefix/.chef/config.rb" "$pkg_prefix/config/client-config.rb"
  cat << EOF >> "$pkg_prefix/config/client-config.rb"
ssl_verify_mode {{cfg.ssl_verify_mode}}
node_name "{{sys.hostname}}"
ENV['PATH'] = "{{cfg.env_path_prefix}}:#{ENV['PATH']}"
{{#if cfg.data_collector.enable ~}}
chef_guid "{{sys.member_id}}"
data_collector.token "{{cfg.data_collector.token}}"
data_collector.server_url "{{cfg.data_collector.server_url}}"
{{/if ~}}
EOF
  chmod 0640 "$pkg_prefix/config/client-config.rb"

  cat << EOF >> "$pkg_prefix/config/attributes.json"
{{#if cfg.attributes ~}}
{{toJson cfg.attributes}}
{{else ~}}
{}
{{/if ~}}
EOF
}