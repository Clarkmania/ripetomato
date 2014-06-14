<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>Firmware Upgrade</title>
<content><script type="text/javascript">
		// <% nvram("jffs2_on"); %>

		function clock()
		{
			var t = ((new Date()).getTime() - startTime) / 1000;
			elem.setInnerHTML('afu-time', Math.floor(t / 60) + ':' + Number(Math.floor(t % 60)).pad(2));
		}
		function upgrade()
		{
			var name;
			var i;
			var fom = document.form_upgrade;
			var ext;
			name = fixFile(fom.file.value);
			if (name.search(/\.(bin|trx|chk)$/i) == -1) {
				alert('Expecting a ".bin", ".trx" or ".chk" file.');
				return false;
			}
			if (!confirm('Are you sure you want to upgrade using ' + name + '?')) return;
			E('afu-upgrade-button').disabled = true;
			elem.display('afu-progress', true);
			startTime = (new Date()).getTime();
			setInterval('clock()', 800);
			fom.action += '?_reset=' + (E('f_reset').checked ? "1" : "0");
			form.addIdAction(fom);
			fom.submit();
		}
	</script>
	<div id="afu-input">

		<div class="alert">
			<h5>Warning</h5>There has been many reports how AdvancedTomato did not flash well or it came with many bugs. Reason for that is bad image files which can sometimes get corupted at the download process.
			This message is here to warn you to check MD5 checksum ( <a target="_blank" href="http://en.wikipedia.org/wiki/Checksum">HELP</a> ) before flashing any images to your router.
			By using this process and learning if image is corupted or not, you will eliminate many issues with the upgrade process.
		</div><br />

		<div class="section">
			<form name="form_upgrade" method="post" action="upgrade.cgi" encType="multipart/form-data">
				<label>Select the file to use:</label>
				<input class="uploadfile" type="file" name="file" size="50"> <button type="button" value="Upgrade" id="afu-upgrade-button" onclick="upgrade()" class="btn btn-danger">Upgrade <i class="icon-upload"></i></button>
			</form>
			<br><form name="form_reset" action="javascript:{}">
				<div id="reset-input">
					<label class="checkbox">
						<input type="checkbox" id="f_reset">&nbsp;&nbsp;After flashing, erase all data in NVRAM memory
					</label>
				</div>
			</form>

			<br>
			<table class="data-table">
				<tr><td>Current Version:</td><td>&nbsp; <% version(1); %> <small></td></tr>
				<script type="text/javascript">
					//	<% sysinfo(); %>
					W('<tr><td>Free Memory:</td><td>&nbsp; ' + scaleSize(sysinfo.totalfreeram) + ' &nbsp; <small>(aprox. size that can be buffered completely in RAM)</small></td></tr>');
				</script>
			</table>

		</div>
	</div>


	<div id="afu-progress" style="margin:auto;display:none;" class="alert alert-info">
		<div id="refresh-spinner" class="spinner" style="vertical-align:baseline"></div> &nbsp; <span id="afu-time">0:00</span><br>
		Please wait while the firmware is uploaded &amp; flashed.<br>
		<b>Warning:</b> Do not interrupt this browser or the router!<br>
	</div>

	/* JFFS2-BEGIN */
	<div class="note-disabledw alert alert-error" style="display:none;" id="jwarn">
		<b>Cannot upgrade if JFFS is enabled.</b><br />
		An upgrade may overwrite the JFFS partition currently in use. Before upgrading,
		please backup the contents of the JFFS partition, disable it, then reboot the router.<br>
		<a href="admin-jffs2.asp">Disable &raquo;</a>
	</div>
	<script type="text/javascript">
		if (nvram.jffs2_on != '0') {
			E('jwarn').style.display = '';
			E('afu-input').style.display = 'none';
		}
	</script>
	/* JFFS2-END */
</content>