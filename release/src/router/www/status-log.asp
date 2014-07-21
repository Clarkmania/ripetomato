<title>Router Logs</title>
<content>
	<style>
		tr.notice td:nth-child(2) { background-color: #dff0d8; }
		tr.info td:nth-child(2) { background-color: #d9edf7; }
		tr.warn td:nth-child(2) { background-color: #fcf8e3; }
		tr.err td:nth-child(2) { background-color: #f2dede; }
		tr.debug td:nth-child(2) { background-color: #f2eefe; }
		#grid td { vertical-align: top; }
		.co1 { white-space: nowrap; display: block; }
		.co5 { white-space: nowrap; display: block; }
	</style>
	<script type="text/javascript">
		//	<% nvram("at_update,tomatoanon_answer,log_file"); %>

		function find()
		{
			var s = E('find-text').value;
			if (s.length) {
				ref.postData = 'find=' + escapeCGI(s);
				ref.start();
			}
		}
		function lines(num)
		{
			if (num > 0) {
				ref.postData = 'which=' + num.toString();
				ref.start();
			}
		}

		function init()
		{
			var e = E('find-text');
			if (e) e.onkeypress = function(ev) {
				if (checkEvent(ev).keyCode == 13) find();
			}

			if (nvram.log_file != '1') {
				$('#logging').replaceWith('<div class="alert alert-info">Internal logging disabled.</b><br><br><a href="admin-log.asp">Enable &raquo;</a></div>');
				return;
			}

			grid.setup();

			ref.initPage(-1);
			ref.once = 1;
			ref.start();
		}

		var ref = new TomatoRefresh('logs/view.cgi', 'which=25', 0, '');

		ref.refresh = function(text)
		{
			try {
				grid.lastClicked = null;
				grid.removeAllData();

				var lines = text.split('\n');
				while(lines.length > 0) {
					i = lines.pop();
					if (b = i.match(/^(\w+ \d+ \d{2}:\d{2}:\d{2}) (\w+) (\w+)\.(\w+) ([^\[\s]+\[?\d+?\]?): (.*)?/)) {
						grid.insertData(-1, [b[1], b[3], b[4], b[5], b[6]], b[4]);
					}
				}
			} catch(ex) {
				console.log(ex);
			}
		}

                var grid = new TomatoGrid();

                grid.setup = function() {
			this.init('grid', 'sort');
			this.headerSet(['Date', 'Facility', 'Tag', 'Message']);
                }

                grid.dataToView = function(data) {
                        var s, v = [];
			for (var col = 0; col < data.length; ++col) {
				if (col == 2)
					s = s + '.' + data[col];
				else
					s = data[col];
				if (col != 1)
					v.push('' + s);
                        }
                        return v;
                }

	</script>

	<div class="box" id="logging">
		<div class="heading">
			<label>View last:</label> 
			<button type="button" value="25" id="25-button" onclick="lines(25);" class="btn btn-primary">25</button>
			<button type="button" value="50" id="50-button" onclick="lines(50);" class="btn btn-primary">50</button>
			<button type="button" value="100" id="100-button" onclick="lines(100);" class="btn btn-primary">100</button>
			<button type="button" value="all" id="all-button" onclick="lines(0);" class="btn btn-primary">All</button>
			<div class="input-append pull-right">
				<input type="text" maxsize="32" id="find-text"> <button value="Find" onclick="find()" class="btn">Find <i class="icon-search"></i></button>
			</div>
		</div>
		<div class="content">
			<table id="grid" class="line-table"></table>
		</div>
	</div>
	<a href="logs/syslog.txt?_http_id=<% nv(http_id) %>">Download Log File</a><br><br>
	&nbsp; &raquo; &nbsp;<a class="ajaxload" href="admin-log.asp">Logging Configuration</a><br><br>

	<script type="text/javascript">init()</script>
</content>
