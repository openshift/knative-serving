#!/usr/bin/env bash

function resolve_resources(){
  local dir=$1
  local resolved_file_name=$2
  local image_tag=$3

  [[ -n $image_tag ]] && image_tag=":$image_tag"

  echo "Writing resolved yaml to $resolved_file_name"

  > "$resolved_file_name"

  for yaml in `find $dir -name "*.yaml" | sort`; do
    resolve_file "$yaml" "$resolved_file_name" "$image_tag"
  done
}

function resolve_file() {
  local file=$1
  local to=$2
  local image_tag=$4

  # Skip cert-manager, it's not part of upstream's release YAML either.
  if grep -q 'networking.knative.dev/certificate-provider: cert-manager' "$1"; then
    return
  fi

  # Skip nscert, it's not part of upstream's release YAML either.
  if grep -q 'networking.knative.dev/wildcard-certificate-provider: nscert' "$1"; then
    return
  fi

  # Skip istio resources, as we use kourier.
  if grep -q 'networking.knative.dev/ingress-provider: istio' "$1"; then
    return
  fi

  # TODO:
  # If image_tag is empty (=nigthly CI), use fixed version v0.20.0 for now.
  # Once operator v0.21 was available in downstream, use the default "devel" label with "latest" version.
  # see: https://github.com/knative/operator/commit/cf938baa174e108121624eef353c1794e247cc1b
  [[ -z $image_tag ]] && image_tag="v0.20.0"

  echo "---" >> "$to"
  # Replace serving.knative.dev/release label.
  sed -e "s+serving.knative.dev/release: devel+serving.knative.dev/release: \"${image_tag}\"+" \
      "$file" >> "$to"
}
