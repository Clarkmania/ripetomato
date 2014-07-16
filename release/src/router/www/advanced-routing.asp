<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>Routing</title>
<content>
	<script type="text/javascript" src="js/interfaces.js"></script>
	<script type="text/javascript">
		// <% nvram("at_update,tomatoanon_answer,wk_mode,dr_setting,lan_stp,routes_static,dhcp_routes,lan_ifname,lan1_ifname,lan2_ifname,lan3_ifname,lan4_ifname,lan5_ifname,lan6_ifname,lan7_ifname,wan_ifname,wan_iface,emf_enable,dr_lan_rx,dr_lan1_rx,dr_lan2_rx,dr_lan3_rx,dr_lan4_rx,dr_lan5_rx,dr_lan6_rx,dr_lan7_rx,dr_wan_rx,wan_proto"); %>
		// <% activeroutes(); %>

		var ara = new TomatoGrid();

		ara.setup = function() {
			var i, a;
			this.init('ara-grid', 'sort');
			this.headerSet(['Destination', 'Gateway / Next Hop', 'Subnet Mask', 'Metric', 'Interface']);
			for (i = 0; i < activeroutes.length; ++i) {
				a = activeroutes[i];
				if (a[0] == nvram.wan_iface) {
					a[0] += ' (WAN)';
				} else if (a[0] == nvram.wan_ifname) {
					a[0] += ' (MAN)';
				} else {
					for (var x = 0; x <= MAX_BRIDGE_ID; x++) {
						var j = (x == 0) ? "" : x;
						if (a[0] == nvram['lan'+j+'_ifname'])
							a[0] += ' (LAN'+j+')';
					}
				}
				this.insertData(-1, [a[1],a[2],a[3],a[4],a[0]]);
			}
		}
		var ars = new TomatoGrid();
		ars.verifyFields = function(row, quiet) {
			var f = fields.getAll(row);
			f[5].value = f[5].value.replace('>', '_');
			return v_ip(f[0], quiet) && v_ip(f[1], quiet) && v_netmask(f[2], quiet) && v_range(f[3], quiet, 0, 10) && v_nodelim(f[5], quiet, 'Description');
		}
		ars.setup = function() {
			var arslanopts = [['WAN','WAN'],['MAN','MAN']];
		        for (var i = 0; i <= MAX_BRIDGE_ID; i++) {
				var ln = (i == 0) ? "" : i;
				arslanopts.unshift.apply(arslanopts, [['LAN'+ln],['LAN'+ln]]);
			}
			this.init('ars-grid', '', 20, [
				{ type: 'text', maxlen: 15 }, { type: 'text', maxlen: 15 }, { type: 'text', maxlen: 15 },
				{ type: 'text', maxlen: 3 }, { type: 'select', options: arslanopts }, { type: 'text', maxlen: 32 }]);
			this.headerSet(['Destination', 'Gateway', 'Subnet Mask', 'Metric', 'Interface', 'Description']);
			var routes = nvram.routes_static.split('>');
			for (var i = 0; i < routes.length; ++i) {
				var r;
				if (r = routes[i].match(/^(.+)<(.+)<(.+)<(\d+)<(LAN\d?|WAN|MAN)<(.*)$/)) {
					this.insertData(-1, [r[1], r[2], r[3], r[4], r[5],r[6]]);
				}
			}
			this.showNewEditor();
			this.resetNewEditor();
		}

		ars.resetNewEditor = function() {
			var i, e;

			e = fields.getAll(this.newEditor);

			/* VLAN-BEGIN */
		        for (var i = 0; i <= MAX_BRIDGE_ID; i++) {
				var ln = (i == 0) ? "" : i;
				if (nvram['lan'+ln+'_ifname'].length < 1)
					e[4].options[i].disabled = true;
				else
					e[4].options[i].disabled = false;
			}
			/* VLAN-END */

			ferror.clearAll(e);
			for (i = 0; i < e.length; ++i) {
				var f = e[i];
				if (f.selectedIndex) f.selectedIndex = 0;
				else f.value = '';
			}
			try { if (e.length) e[0].focus(); } catch (er) { }
		}

		function verifyFields(focused, quiet)
		{
			/* VLAN-BEGIN */
		        for (var i = 0; i <= MAX_BRIDGE_ID; i++) {
				var ln = (i == 0) ? "" : i;
				E('_f_dr_lan'+ln).disabled = (nvram['lan'+ln+'_ifname'].length < 1);
				if (E('_f_dr_lan'+ln).disabled)
					E('_f_dr_lan'+ln).checked = false;
			}
			E('_f_dr_wan').disabled = (nvram.wan_proto.length == 'disabled');
			if (E('_f_dr_wan') == null || E('_f_dr_wan').disabled)
				E('_f_dr_wan').checked = false;
			/* VLAN-END */
			return 1;
		}

		function save()
		{
			if (ars.isEditing()) return;

			var fom = E('_fom');
			var data = ars.getAllData();
			var r = [];
			for (var i = 0; i < data.length; ++i) r.push(data[i].join('<'));
			fom.routes_static.value = r.join('>');

			/* ZEBRA-BEGIN */

			/* NOVLAN-BEGIN */
			var wan = '0';
			var lan = '0';

			switch (E('_dr_setting').value) {
				case '1':
					lan = '1 2';
					break;
				case '2':
					wan = '1 2';
					break;
				case '3':
					lan = '1 2';
					wan = '1 2';
					break;
			}
			fom.dr_lan_tx.value = fom.dr_lan_rx.value = lan;
			fom.dr_wan_tx.value = fom.dr_wan_rx.value = wan;
			/* NOVLAN-END */

			/* VLAN-BEGIN */
		        for (var i = 0; i <= MAX_BRIDGE_ID; i++) {
				var ln = (i == 0) ? "" : i;
				fom['dr_lan'+ln+'_tx'].value = fom['dr_lan'+ln+'_rx'].value = (E('_f_dr_lan'+ln).checked) ? '1 2' : '0';
			}
			fom.dr_wan_tx.value = fom.dr_wan_rx.value = (E('_f_dr_wan').checked) ? '1 2' : '0';
			/* VLAN-END */

			/* ZEBRA-END */

			/* NOVLAN-BEGIN */
			fom.lan_stp.value = E('_f_stp').checked ? 1 : 0;
			/* NOVLAN-END */

			fom.dhcp_routes.value = E('_f_dhcp_routes').checked ? '1' : '0';
			fom._service.value = (fom.dhcp_routes.value != nvram.dhcp_routes) ? 'wan-restart' : 'routing-restart';

			/* EMF-BEGIN */
			fom.emf_enable.value = E('_f_emf').checked ? 1 : 0;
			if (fom.emf_enable.value != nvram.emf_enable) fom._service.value = '*';
			/* EMF-END */

			form.submit(fom, 1);
		}

		function submit_complete()
		{
			reloadPage();
		}

		function earlyInit()
		{
			ara.setup();
			ars.setup();
			init();
		}

		function init()
		{
			ara.recolor();
			ars.recolor();
		}
	</script>

	<form id="_fom" method="post" action="tomato.cgi">
		<input type="hidden" name="_nextpage" value="/#advanced-routing.asp">
		<input type="hidden" name="_service" value="routing-restart">

		<input type="hidden" name="routes_static">
		<input type="hidden" name="dhcp_routes">
		<input type="hidden" name="emf_enable">
		<!-- NOVLAN-BEGIN -->
		<input type="hidden" name="lan_stp">
		<!-- NOVLAN-END -->
		<input type="hidden" name="dr_lan_tx">
		<input type="hidden" name="dr_lan_rx">
		<!-- VLAN-BEGIN -->
		<input type="hidden" name="dr_lan1_tx">
		<input type="hidden" name="dr_lan1_rx">
		<input type="hidden" name="dr_lan2_tx">
		<input type="hidden" name="dr_lan2_rx">
		<input type="hidden" name="dr_lan3_tx">
		<input type="hidden" name="dr_lan3_rx">
		<input type="hidden" name="dr_lan4_tx">
		<input type="hidden" name="dr_lan4_rx">
		<input type="hidden" name="dr_lan5_tx">
		<input type="hidden" name="dr_lan5_rx">
		<input type="hidden" name="dr_lan6_tx">
		<input type="hidden" name="dr_lan6_rx">
		<input type="hidden" name="dr_lan7_tx">
		<input type="hidden" name="dr_lan7_rx">
		<!-- VLAN-END -->
		<input type="hidden" name="dr_wan_tx">
		<input type="hidden" name="dr_wan_rx">

		<h3>Current Routing Table</h3>
		<div class="section">
			<table class="line-table" id="ara-grid"></table>
		</div>

		<h3>Static Routing Table</h3>
		<div class="section">
			<table class="line-table" id="ars-grid"></table>
		</div>

		<h3>Miscellaneous</h3>
		<div class="section misc">
			<script type="text/javascript">
				var mto = [
					{ title: 'Mode', name: 'wk_mode', type: 'select', options: [['gateway','Gateway'],['router','Router']], value: nvram.wk_mode }
				];
				/* ZEBRA-BEGIN */
				/* VLAN-BEGIN */
				mto.push.apply(mto, [{ title: 'RIPv1 &amp; v2' }]);
				for (var i = 0; i <= MAX_BRIDGE_ID; i++) {
					var ln = (i == 0) ? "" : i;
					mto.push.apply(mto, [{ title: 'LAN'+ln, indent: 2, name: 'f_dr_lan'+ln, type: 'checkbox', value: ((nvram['dr_lan'+ln+'_rx'] != '0') && (nvram['dr_lan'+ln+'_rx'] != '')) }]);
				}
				mto.push.apply(mto, [{ title: 'WAN', indent: 2, name: 'f_dr_wan', type: 'checkbox', value: ((nvram.dr_wan_rx != '0') && (nvram.dr_wan_rx != '')) }]);
				/* VLAN-END */
				/* NOVLAN-BEGIN */
				mto.push.apply(mto, [{ title: 'RIPv1 &amp; v2', name: 'dr_setting', type: 'select', options: [[0,'Disabled'],[1,'LAN'],[2,'WAN'],[3,'Both']], value: nvram.dr_setting }]);
				/* NOVLAN-END */
				/* ZEBRA-END */
				/* EMF-BEGIN */
				mto.push.apply(mto, [{ title: 'Efficient Multicast Forwarding', name: 'f_emf', type: 'checkbox', value: nvram.emf_enable != '0' }]);
				/* EMF-END */
				mto.push.apply(mto, [{ title: 'DHCP Routes', name: 'f_dhcp_routes', type: 'checkbox', value: nvram.dhcp_routes != '0' }]);
				/* NOVLAN-BEGIN */
				mto.push.apply(mto, [{ title: 'Spanning-Tree Protocol', name: 'f_stp', type: 'checkbox', value: nvram.lan_stp != '0' }]);
				/* NOVLAN-END */
				createFieldTable('', mto, '.section.misc', 'fields-table');
			</script>
		</div>

		<br />
		<button type="button" value="Save" id="save-button" onclick="save()" class="btn btn-primary">Save <i class="icon-check"></i></button>
		<button type="button" value="Cancel" id="cancel-button" onclick="javascript:reloadPage();" class="btn">Cancel <i class="icon-cancel"></i></button>
		&nbsp; <span id="footer-msg" class="alert warning" style="visibility: hidden;"></span>

	</form>

	<script type="text/javascript">earlyInit(); verifyFields(null, 1);</script>
</content>