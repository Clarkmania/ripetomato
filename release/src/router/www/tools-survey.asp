<!DOCTYPE html>
<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>Wireless Survey</title>
<content>
	<style type="text/css">
		#survey-grid .brate {
			color: blue;
		}
		#survey-grid .grate {
			color: green;
		}
		#survey-grid .co4,
		#survey-grid .co5 {
			text-align: right;
		}
		#survey-grid .co6,
		#survey-grid .co7 {
			text-align: center;
		}
		#survey-msg {

		}
		#survey-controls {
			text-align: right;
		}
		#expire-time {
			width: 120px;
		}
	</style>
	<script type="text/javascript">
		var wlscandata = [];
		var entries = [];
		var dayOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

		Date.prototype.toWHMS = function() {
			return dayOfWeek[this.getDay()] + ' ' + this.getHours() + ':' + this.getMinutes().pad(2)+ ':' + this.getSeconds().pad(2);
		}

		var sg = new TomatoGrid();

		sg.sortCompare = function(a, b) {
			var col = this.sortColumn;
			var da = a.getRowData();
			var db = b.getRowData();
			var r;

			switch (col) {
				case 0:
					r = -cmpDate(da.lastSeen, db.lastSeen);
					break;
				case 3:
					r = cmpInt(da.rssi, db.rssi);
					break;
				case 4:
					r = cmpInt(da.noise, db.noise);
					break;
				case 5:
					r = cmpInt(da.qual, db.qual);
					break;
				case 6:
					r = cmpInt(da.channel, db.channel);
					break;
				default:
					r = cmpText(a.cells[col].innerHTML, b.cells[col].innerHTML);
			}
			if (r == 0) r = cmpText(da.bssid, db.bssid);

			return this.sortAscending ? r : -r;
		}

		sg.rateSorter = function(a, b)
		{
			if (a < b) return -1;
			if (a > b) return 1;
			return 0;
		}

		sg.populate = function()
		{
			var caps = ['infra', 'adhoc', 'poll', 'pollreq', 'wep', 'shortpre', 'pbcc', 'agility', 'spectrum', null, 'shortslot', null, null, 'cck-ofdm'];
			var ncaps = [null, null /*40MHz*/, null, null, 'gf', 'sgi20', 'sgi40', 'stbc'];
			var ncap = '802.11n';
			var cap_maxlen = 14;
			var added = 0;
			var removed = 0;
			var i, j, k, t, e, s;

			if ((wlscandata.length == 1) && (!wlscandata[0][0])) {
				setMsg("error: " + wlscandata[0][1]);
				return;
			}

			for (i = 0; i < wlscandata.length; ++i) {
				s = wlscandata[i];
				e = null;

				for (j = 0; j < entries.length; ++j) {
					if (entries[j].bssid == s[0]) {
						e = entries[j];
						break;
					}
				}
				if (!e) {
					++added;
					e = {};
					e.firstSeen = new Date();
					entries.push(e);
				}
				e.lastSeen = new Date();
				e.bssid = s[0];
				e.ssid = s[1];
				e.channel = s[2];
				if (s[7] != 0 && s[9] != 0) {
					e.channel = e.channel + '<br><small>' + s[9] + ' MHz</small>';
				}
				e.rssi = s[4];
				e.noise = s[5];
				e.saw = 1;

				t = '';
				k = 0;
				for (j = 0; j < caps.length; ++j) {
					if ((s[3] & (1 << j)) && (caps[j])) {
						k += caps[j].length;
						if (k > cap_maxlen) {
							t += '<br>';
							k = caps[j].length;
						}
						else t += ' ';
						t += caps[j];
					}
				}

				if (s[7] != 0) {
					k += ncap.length;
					if (k > cap_maxlen) {
						t += '<br>';
						k = ncap.length;
					}
					else t += ' ';
					t += ncap;
				}

				for (j = 0; j < ncaps.length; ++j) {
					if ((s[8] & (1 << j)) && (ncaps[j])) {
						k += ncaps[j].length;
						if (k > cap_maxlen) {
							t += '<br>';
							k = ncaps[j].length;
						}
						else t += ' ';
						t += ncaps[j];
					}
				}

				e.cap = t;

				t = '';
				var rb = [];
				var rg = [];
				for (j = 0; j < s[6].length; ++j) {
					var x = s[6][j];
					var r = (x & 0x7F) / 2;
					if (x & 0x80) rb.push(r);
					else rg.push(r);
				}
				rb.sort(this.rateSorter);
				rg.sort(this.rateSorter);

				t = '';
				if (rb.length) t = '<span class="brate">' + rb.join(',') + '</span>';
				if (rg.length) {
					if (rb.length) t += '<br>';
					t +='<span class="grate">' + rg.join(',') + '</span>';
				}
				e.rates = t;
			}

			// t = E('expire-time').value;
			if (t > 0) {
				var cut = (new Date()).getTime() - (t * 1000);
				for (i = 0; i < entries.length; ) {
					if (entries[i].lastSeen.getTime() < cut) {
						entries.splice(i, 1);
						++removed;
					}
					else ++i;
				}
			}

			for (i = 0; i < entries.length; ++i) {
				var seen, m, mac;

				e = entries[i];

				if (!e.saw) {
					e.rssi = MAX(e.rssi - 5, -101);
					e.noise = MAX(e.noise - 2, -101);
					if ((e.rssi == -101) || (e.noise == -101))
						e.noise = e.rssi = -999;
				}
				e.saw = 0;

				e.qual = MAX(e.rssi - e.noise, 0);

				seen = e.lastSeen.toWHMS();
				if (useAjax()) {
					m = Math.floor(((new Date()).getTime() - e.firstSeen.getTime()) / 60000);
					if (m <= 10) seen += '<br> <b><small>NEW (' + -m + 'm)</small></b>';
				}

				mac = e.bssid;
				if (mac.match(/^(..):(..):(..)/))
					mac = '<a href="http://standards.ieee.org/cgi-bin/ouisearch?' + RegExp.$1 + '-' + RegExp.$2 + '-' + RegExp.$3 + '" target="_new" title="OUI search">' + mac + '</a>';

				sg.insert(-1, e, [
					'<small>' + seen + '</small>',
					'' + e.ssid,
					mac,
					(e.rssi == -999) ? '' : (e.rssi + ' <small>dBm</small>'),
					(e.noise == -999) ? '' : (e.noise + ' <small>dBm</small>'),
					'<small>' + e.qual + '</small> <i class="icon-wifi-' + MIN(MAX(Math.floor(e.qual / 10), 1), 3) + '"></i>',
					'' + e.channel,
					'' + e.cap,
					'' + e.rates], false);
			}

			s = '';
			if (useAjax()) s = added + ' added, ' + removed + ' removed, ';
			s += entries.length + ' total.';

			s += '<br><small>Last updated: ' + (new Date()).toWHMS() + '</small>';
			setMsg(s);

			wlscandata = [];
		}

		sg.setup = function() {
			this.init('survey-grid', 'sort');
			this.headerSet(['<b>Last Seen</b>', '<b>SSID</b>', '<b>BSSID</b>', '<b>RSSI</b> &nbsp; &nbsp; ', '<b>Noise</b> &nbsp; &nbsp; ', '<b>Quality</b>', '<b>Ch</b>', '<b>Capabilities</b>', '<b>Rates</b>']);
			this.populate();
			this.sort(0);
		}


		function setMsg(msg)
		{
			E('survey-msg').innerHTML = msg;
		}


		var ref = new TomatoRefresh('/update.cgi', 'exec=wlscan', 0, 'tools_survey_refresh');

		ref.refresh = function(text)
		{
			try {
				eval(text);
			}
			catch (ex) {
				return;
			}
			sg.removeAllData();
			sg.populate();
			sg.resort();
		}

		function earlyInit() {    
			if (!useAjax()) E('expire-time').style.visibility = 'hidden';
			sg.setup();
			sg.recolor();
			$('.input-append .spinner').after('&nbsp; ' + genStdTimeList('expire-time', 'Auto Expire', 1) + genStdTimeList('refresh-time', 'Auto Refresh', 1));
			ref.initPage();
		}

	</script>

	<ul class="nav-tabs">
		<li><a class="ajaxload" href="tools-ping.asp">Ping</a></li>
		<li><a class="ajaxload" href="tools-trace.asp">Trace</a></li>
		<li><a class="ajaxload" href="tools-shell.asp">System Commands</a></li>
		<li><a class="active">Wireless Survey</a></li>
		<li><a class="ajaxload" href="tools-wol.asp">WOL</a></li>
	</ul>

	<div class="section">
	
		<br /><table id="survey-grid" class="line-table"></table>
		<br />
		<div id="survey-msg"></div>
		<div id="survey-controls">
			<div class="input-append"><div class="spinner"></div>
				<button type="button" value="Refresh" onclick="ref.toggle()" id="refresh-button" class='btn'>Refresh <i class="icon-reboot"></i></button>
			</div>
		</div>

		<script type="text/javascript">
			if ('<% wlclient(); %>' == '0') {
				$('.section').prepend('<div class="alert alert-warning">Warning: Wireless connections to this router may be disrupted while using this tool.</div>');
			}
		</script>
	</div>

	<script type="text/javascript">earlyInit();</script>
</content>