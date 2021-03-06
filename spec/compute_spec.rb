# frozen_string_literal: true

# Copyright 2018 Tristan Robert

# This file is part of Fog::Proxmox.

# Fog::Proxmox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Fog::Proxmox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Fog::Proxmox. If not, see <http://www.gnu.org/licenses/>.

require 'spec_helper'
require_relative './proxmox_vcr'

describe Fog::Compute::Proxmox do
  before :all do
    @proxmox_vcr = ProxmoxVCR.new(
      vcr_directory: 'spec/fixtures/proxmox/compute',
      service_class: Fog::Compute::Proxmox
    )
    @service = @proxmox_vcr.service
    @pve_url = @proxmox_vcr.url
    @username = @proxmox_vcr.username
    @password = @proxmox_vcr.password
    @ticket = @proxmox_vcr.ticket
    @csrftoken = @proxmox_vcr.csrftoken
  end

  it 'Manage tasks' do
    VCR.use_cassette('tasks') do
      # List all tasks
      options = { limit: 1 }
      node_name = 'pve'
      node = @service.nodes.find_by_id node_name
      tasks = node.tasks.search(options)
      tasks.wont_be_nil
      tasks.wont_be_empty
      # Get task
      upid = tasks[0].upid
      task = node.tasks.find_by_id(upid)
      task.wont_be_nil
      # Stop task
      task.stop
      task.exitstatus.must_equal 'OK'
    end
  end

  it 'Manage nodes' do
    VCR.use_cassette('nodes') do
      # Get node
      node_name = 'pve'
      node = @service.nodes.find_by_id node_name
      # Get statistics data
      data = node.statistics
      data.wont_be_nil
      data.wont_be_empty
      # Get statistics image
      data = node.statistics('rrd', { timeframe: 'hour', ds: 'cpu,memused', cf: 'AVERAGE' })
      data.wont_be_nil
      data['image'].wont_be_nil
    end
  end

  it 'Manage storages' do
    VCR.use_cassette('storages') do
      # Get node
      node_name = 'pve'
      node = @service.nodes.find_by_id node_name
      # List all storages
      storages = node.storages.all
      storages.wont_be_nil
      storages.wont_be_empty
      # List by content type
      storages = node.storages.list_by_content_type 'iso'
      storages.wont_be_nil
      storages.wont_be_empty
      # Get storage
      storage = node.storages.find_by_id('local')
      storage.wont_be_nil
    end
  end

  it 'CRUD servers' do
    VCR.use_cassette('servers') do
      node_name = 'pve'
      node = @service.nodes.find_by_id node_name
      # Get next vmid
      vmid = node.servers.next_id
      server_hash = { vmid: vmid }
      # Check valid vmid
      valid = node.servers.id_valid? vmid
      valid.must_equal true
      # Check not valid vmid
      valid = node.servers.id_valid? 99
      valid.must_equal false
      # Create 1st time
      node.servers.create(server_hash)
      # Check already used vmid
      valid = node.servers.id_valid? vmid
      valid.must_equal false
      # Clone server
      newid = node.servers.next_id
      # Get server
      server = node.servers.get vmid
      server.wont_be_nil
      # Backup it
      server.backup(compress: 'lzo')
      # Get this backup image
      # Find available backup volumes
      volume = server.backups.first
      volume.wont_be_nil
      # Restore it
      server.restore(volume, storage: 'local')
      # Delete it
      volume.destroy
      # Add hdd
      # Find available storages with images
      storages = node.storages.list_by_content_type 'images'
      storage = storages[0]
      virtio0 = { id: 'virtio0', storage: storage.storage, size: '1' }
      ide0 = { id: 'ide0', storage: storage.storage, size: '1' }
      options = { backup: 0, replicate: 0 }
      server.attach(virtio0, options)
      server.attach(ide0, options)
      server.detach('ide0')
      server.detach('unused0')
      sleep 1
      # Clone it (linked fails)
      server.clone(newid, full: 1)
      # Get clone
      clone = node.servers.get newid
      # Template this clone (read-only)
      clone.template
      # Get clone disk image
      image = clone.images.first
      image.wont_be_nil
      # Delete clone
      clone.destroy
      proc do
        node.servers.get newid
      end.must_raise Excon::Errors::InternalServerError
      # Create 2nd time must fails
      proc do
        node.servers.create server_hash
      end.must_raise Excon::Errors::InternalServerError
      # Update config server
      # Add empty cdrom
      config_hash = { ide2: 'none,media=cdrom' }
      server.update(config_hash)
      # Resize disk server
      server.extend('virtio0', '+1G')
      # Move disk server
      server.move('virtio0', 'local')
      # Add network interface
      config_hash = { net0: 'virtio,bridge=vmbr0' }
      server.update(config_hash)
      # Add start at boot, keyboard fr,
      # linux 4.x os type, kvm hardware disabled (proxmox guest in virtualbox) and vga enabled to console
      config_hash = { onboot: 1, keyboard: 'fr', ostype: 'l26', kvm: 0 }
      server.update(config_hash)
      # server config
      config = server.config
      config.identity.must_equal vmid
      disks = server.config.disks
      nics = server.config.interfaces
      nics.wont_be_nil
      nics.wont_be_empty
      nics.get('net0').wont_be_nil
      disks.wont_be_nil
      disks.wont_be_empty
      virtio0 = disks.get('virtio0')
      virtio0.wont_be_nil
      ide2 = disks.get('ide2')
      ide2.wont_be_nil
      # Get a mac adress
      mac_address = server.config.mac_addresses.first
      mac_address.wont_be_nil
      # all servers
      servers_all = node.servers.all
      servers_all.wont_be_nil
      servers_all.wont_be_empty
      servers_all.must_include server
      # server not running exception
      proc do
        server.start_console(websocket: 1)
      end.must_raise Fog::Proxmox::Errors::ServiceError
      # Start server
      server.action('start')
      server.wait_for { ready? }
      status = server.ready?
      status.must_equal true
      # server vga not set exception
      proc do
        server.start_console(websocket: 1)
      end.must_raise Fog::Proxmox::Errors::ServiceError
      # Stop server
      server.action('stop')
      server.wait_for { server.status == 'stopped' }
      status = server.status
      status.must_equal 'stopped'
      server.update(vga: 'std')
      # Start server
      server.action('start')
      server.wait_for { ready? }
      status = server.ready?
      status.must_equal true
      vnc = server.start_console(websocket: 1)
      vnc['cert'].wont_be_nil
      port = server.connect_vnc(vnc)
      port.wont_be_nil
      # Stop server
      server.action('stop')
      server.wait_for { server.status == 'stopped' }
      status = server.status
      status.must_equal 'stopped'
      server.update(serial0: 'socket', vga: 'serial0')
      # Start server
      server.action('start')
      server.wait_for { ready? }
      status = server.ready?
      status.must_equal true
      term = server.start_console
      term['ticket'].wont_be_nil
      # Stop server
      server.action('stop')
      server.wait_for { server.status == 'stopped' }
      status = server.status
      status.must_equal 'stopped'
      server.update(vga: 'qxl')
      # Start server
      server.action('start')
      server.wait_for { ready? }
      status = server.ready?
      status.must_equal true
      spice = server.start_console
      spice['password'].wont_be_nil
      # Suspend server
      server.action('suspend')
      server.wait_for { server.qmpstatus == 'paused' }
      qmpstatus = server.qmpstatus
      qmpstatus.must_equal 'paused'
      # Resume server
      server.action('resume')
      server.wait_for { ready? }
      status = server.ready?
      status.must_equal true
      # Stop server
      server.action('stop')
      server.wait_for { server.status == 'stopped' }
      status = server.status
      status.must_equal 'stopped'
      proc do
        server.action('hello')
      end.must_raise Fog::Errors::Error
      # Delete
      server.destroy
      proc do
        node.servers.get vmid
      end.must_raise Excon::Errors::InternalServerError
    end
  end

  it 'CRUD snapshots' do
    VCR.use_cassette('snapshots') do
      node_name = 'pve'
      node = @service.nodes.find_by_id node_name
      vmid = node.servers.next_id
      server_hash = { vmid: vmid }
      node.servers.create server_hash
      # Create
      snapname = 'snapshot1'
      server = node.servers.get vmid
      snapshot_hash = { snapname: snapname }
      server.snapshots.create(snapshot_hash)
      # Find by id
      snapshot = server.snapshots.get snapname
      snapshot.wont_be_nil
      # Update
      snapshot.description = 'Snapshot 1'
      snapshot.update
      # all snapshots
      snapshots_all = server.snapshots.all
      snapshots_all.wont_be_nil
      snapshots_all.wont_be_empty
      snapshots_all.must_include snapshot
      # Delete
      snapshot.destroy
      server.destroy
    end
  end

  it 'CRUD containers' do
    VCR.use_cassette('containers') do
      node_name = 'pve'
      node = @service.nodes.find_by_id node_name
      # Get next vmid
      vmid = node.containers.next_id
      ostemplate = 'local:vztmpl/alpine-3.8-default_20180913_amd64.tar.xz'
      container_hash = { vmid: vmid,
                         storage: 'local-lvm',
                         ostemplate: ostemplate, password: 'proxmox01', rootfs: 'local-lvm:1' }
      # Check valid vmid
      valid = node.containers.id_valid? vmid
      valid.must_equal true
      # Check not valid vmid
      valid = node.containers.id_valid? 99
      valid.must_equal false
      # Create 1st time
      node.containers.create(container_hash)
      # Check already used vmid
      valid = node.containers.id_valid? vmid
      valid.must_equal false
      # Clone container
      newid = node.containers.next_id
      # Get container
      container = node.containers.get vmid
      container.wont_be_nil
      # Backup it
      container.backup(compress: 'lzo')
      # Get this backup image
      # Find available backup volumes
      backup = container.backups.first
      container.wont_be_nil
      # Restore it
      container.restore(backup, storage: 'local-lvm')
      # Delete it
      backup.destroy
      # Add mount points
      # Find available storages with images
      storages = node.storages.list_by_content_type 'images'
      storage = storages[0]
      mp0 = { id: 'mp0', storage: storage.storage, size: '1' }
      options = { mp: '/opt/app', backup: 0, replicate: 0, quota: 1 }
      container.attach(mp0, options)
      # Fetch mount points
      mount_points = container.config.mount_points
      mount_points.wont_be_empty
      mount_points.get('mp0').wont_be_nil
      # Remove mount points
      container.detach('mp0')
      container.detach('unused0')
      sleep 1
      # Clone it
      container.clone(newid)
      # Get clone
      clone = node.containers.get newid
      # Template this clone (read-only)
      clone.template
      # Get clone disk image
      image = clone.images.first
      image.wont_be_nil
      # Delete clone
      clone.destroy
      proc do
        node.containers.get newid
      end.must_raise Excon::Errors::InternalServerError
      # Create 2nd time must fails
      proc do
        node.containers.create container_hash
      end.must_raise Excon::Errors::InternalServerError
      # Update config container
      # Resize rootfs container
      container.extend('rootfs', '+5M')
      # Move rootfs container and delete original
      container.move('rootfs', 'local-lvm', delete: 1)
      # Add network interface
      config_hash = { net0: 'bridge=vmbr0,name=eth0,ip=dhcp,ip6=dhcp' }
      container.update(config_hash)
      # Add start at boot, keyboard fr,
      # linux os type alpine
      config_hash = { onboot: 1, ostype: 'alpine' }
      container.update(config_hash)
      # get container config
      config = container.config
      config.wont_be_nil
      config.identity.must_equal vmid
      # Get a mac address
      mac_address = container.config.mac_addresses.first
      mac_address.wont_be_nil
      # Fetch nics
      interfaces = container.config.interfaces
      interfaces.wont_be_empty
      interfaces.get('net0').wont_be_nil
      # all containers
      containers_all = node.containers.all
      containers_all.wont_be_nil
      containers_all.wont_be_empty
      containers_all.first.vmid.must_equal container.vmid.to_s
      # Start container
      container.action('start')
      container.wait_for { ready? }
      status = container.ready?
      status.must_equal true
      # Suspend container not implemented
      proc do
        container.action('suspend')
      end.must_raise Fog::Errors::Error
      # Resume container not implemented
      proc do
        container.action('resume')
      end.must_raise Fog::Errors::Error
      # Stop container
      container.action('stop')
      container.wait_for { container.status == 'stopped' }
      status = container.status
      status.must_equal 'stopped'
      proc do
        container.action('hello')
      end.must_raise Fog::Errors::Error
      # Delete
      container.destroy
      # Delete container does not delete images
      storage.volumes.each(&:destroy)
      proc do
        node.containers.get vmid
      end.must_raise Excon::Errors::InternalServerError
    end
  end
end
