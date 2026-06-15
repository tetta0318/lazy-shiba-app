import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;

class SubjectsScraping {
  // 抽出した科目名を格納するシンプルなリスト
  List<String> subjectNames = [];

  void getSubjectNames() {
    subjectNames.clear();

    // 1. テスト用の擬似HTML（先頭に `r` をつけて $ エラーを完全回避）
    final String mockHtmlString = r'''
    <!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>時間割</title>
<meta charset="UTF-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta name="viewport" content="width=device-width" />
<link href="/css/jquery-ui.min.css" rel="stylesheet"></link>
<link href="/css/jquery-ui.structure.min.css" rel="stylesheet"></link>
<link href="/css/jquery-ui.theme.min.css" rel="stylesheet"></link>
<link href="/css/page_import.css" rel="stylesheet"></link>
<script src="/js/jquery-3.5.1.min.js"></script>
<script src="/js/jquery.heightLine.js"></script>
<script src="/js/jquery-ui.min.js"></script>
<script src="/js/jquery.ui.touch-punch.min.js"></script>
<script src="/js/common.js"></script>
<script src="/js/pages.js"></script>
<link rel="stylesheet" href="/css/magnific-popup.css">

<script type="text/javascript">
$(document).ready(function(){

	$('#ctrl_btn_info').on('click', function(e) {
		if($(window).width() > 480){
			$('#ctrl_menu_info').offset({ top: (e.pageY+28), left: e.pageX });
		} else {
			$('#ctrl_menu_info').offset({ top: (e.pageY+23), left: 0 });
		}
		$('#ctrl_menu_notification').hide();
	});
	$('#ctrl_btn_notification').on('click', function(e) {
		if($(window).width() > 480){
			$('#ctrl_menu_notification').offset({ top: (e.pageY+28), left: e.pageX });
		} else {
			$('#ctrl_menu_notification').offset({ top: (e.pageY+23), left: 0});
		}
		$('#ctrl_menu_info').hide();
	});
})

$(document).on('click', function(event) {
	if (!$(event.target).closest('.btnControl').length) {
		$('#ctrl_menu_info').hide();
		$('#ctrl_menu_notification').hide();
		if (!$(event.target).closest('.btnControl.relativeBtn').length) {
			var Opentarget = $(this).find(".control-menu");
			$(Opentarget).hide();
	 	}
	}
});

$(document).keydown(ivnt_keydown);
function ivnt_keydown(e) {
	// ESCAPE key pressed
	if (e.keyCode == 27) {
		$('#ctrl_menu_info').hide();
		$('#ctrl_menu_notification').hide();
		$('.control-menu').hide();
	}
}
</script>
<script>

function InfoDetail(event,infoid,idnumber) {

	
	if(typeof progress == "undefined" || progress == null) {
		progress = CommonUtil.createProgress("\u30C7\u30FC\u30BF\u51E6\u7406\u4E2D\u3067\u3059");
		progress.open();
	}

	event.preventDefault();
	var paramUrl = "\/lms\/course\/information\/listdetail";
	if (idnumber != 'null') {
		paramUrl += "?idnumber=" + idnumber;
	}

	$("#informationDtl #informationId").val(infoid);

	var formData = {};
	$($("#informationDtl").serializeArray()).each(function(i, v) {
		formData[v.name] = v.value;
	});

	$(event.currentTarget).find(".info_new_icon").remove();

	$.ajax({
		type : "POST",
		url : paramUrl,
		data : formData,
		dataType : "html",
		cache: false,
	}).done(function(data) {
			$('#info_detail_view2').html(data);

			if($("#info_preview").length == 0){
				CommonFuncMaker.makeCommonAjaxFail()();
			}

			var info_detail_dialog = CommonUtil.createTempleteDialog("info_detail_view2", "90%", 450);
			if($(window).width() > 480){
				info_detail_dialog = CommonUtil.createTempleteDialog("info_detail_view2", 800, 450);
			}
			info_detail_dialog.addBottun("\u9589\u3058\u308B");
			info_detail_dialog.open();
			InfomationOpenCheck();

			
			if(typeof progress !== "undefined" && progress) {
				progress.close();
				progress = null;
			}
	}).fail();

	info_detail_dialog = CommonUtil.createTempleteDialog("info_detail_view2", "90%", 450);
	if($(window).width() > 480){
		info_detail_dialog = CommonUtil.createTempleteDialog("info_detail_view2", 800, 450);
	}
	info_detail_dialog.addBottun("\u9589\u3058\u308B");
	info_detail_dialog.open();

}

function InfomationOpenCheck(){
	if($('#isInformationOpened').val() != null && $('#isInformationOpened').val() == '0'){
		if($('.header-information .header-new-icon').length){
			$('.header-information .header-new-icon').addClass('close-icon');
		}
	}
}
</script>
<meta charset="UTF-8">
<link href="/course/css/timetable.css" rel="stylesheet">
</link>
<script>
$(function() {
	// 起動後、Windowsのサイズによって、表示を変更
	windowWidth = $(window).width();
	if(windowWidth > 480){
		$("[class$='-yobicol']").show();
		$("#roomMessage").html("");
		$("#roomMessage").text($('#roomNoticePc').text());
	}else{
		var selectYobi = $("#timetableSelectYobiForSmart").val();
		$("[class$='-yobicol'][class!='"+selectYobi+"-yobicol']").hide();
		$("." + selectYobi + "-yobicol").show();
		$("#roomMessage").html("");
		$("#roomMessage").text($('#roomNoticeMobile').text());
	}

	// セレクトボックスが切り替わったら発動
	$('.condision-select').change(function() {
		document.getElementById('selectTimetable').submit();
	});

	$('#timetableSelectYobiForSmart').change(function() {
		var selectYobi = $("#timetableSelectYobiForSmart").val();
		$("[class$='-yobicol'][class!='"+selectYobi+"-yobicol']").hide();
		$("." + selectYobi + "-yobicol").show();
	});

	// コースＴＯＰへの遷移（ログ取得後、遷移する）
	$(".timetable-course-top-btn").click(function() {

		// プログレス開始
		if(typeof progress == "undefined" || progress == null) {
			progress = CommonUtil.createProgress("\u30C7\u30FC\u30BF\u51E6\u7406\u4E2D\u3067\u3059");
			progress.open();
		}

		var idnumber = $(this).attr("id");
		var courseName = $(this).text();
		var param = {
			idnumber: idnumber,
			courseName: courseName
		};
		var parent = $(this).parent();
		$.ajax({
			type : "GET",
			url : "/lms/timetable/log",
			data : param,
			cache: false
		}).done(function( data, textStatus, jqXHR ) {
		}).fail(function( jqXHR, textStatus, errorThrown ) {
			//ログ出力に失敗
			writeErrorLog(idnumber, courseName);
		}).always(function() {
			// システム管理者が学生ユーザを参照している場合
			var viewUserNumber = $("#viewUserId").val();
			var permitStudent =$("#permitStudent").val();
			if(viewUserNumber != "" && permitStudent == 'true' && parent.hasClass("permit-student")){
				window.location.href = "\/lms\/course?idnumber=" + idnumber + "&userNumber=" + viewUserNumber;
			}else{
				window.location.href = "\/lms\/course?idnumber=" + idnumber;
			}
		});
	});

	//「今日」ボタン押した状態で維持
	$("#idTodayButton.disabled").click(function() {
		$("#idTodayButton").removeClass('disabled');
	});

	// 教室表示ツールチップ
	$('[data-toggle="tooltip"]').tooltip({html:true});

});
function writeErrorLog(idnumber, courseName){
	$.ajax({
		type : "GET",
		url : "/lms/timetable/ajaxlog",
		data : {
			idnumber: idnumber,
			courseName: courseName
	    },
		cache: false
	});
}

$(function () {
	$('input[name="selectDisplayMode"]').change(function () {
		document.getElementById('selectTimetable').submit();
	});
});

</script>
</head>

<body>
	<div id="contentsWrapper" class="sidemenu-hide clearfix">

		<!--サイドメニュー-->
		<div id="sidemenu" class="sidemenu">
		<div class="sidemenu-head">
			<div class="sidemenu-logo">
				<a href="/portal/home"><img src="/sitelogo" alt="in Campus"></a>
			</div>
			<div id="sidemenuClose" class="sidemenu-close-icon"><img src="/img/side_close.png" alt=""></div>
		</div>

		<!-- main -->
		
			<a class="sidemenu-link sidemenu-lms-link sidemenu-link-txt portal-color sidemenu-icon portal-home-icon" href="/portal/home">ポータルホーム</a>
		
		
			<a class="sidemenu-link sidemenu-lms-link sidemenu-link-txt lms-color sidemenu-icon lms-icon" href="/lms/timetable">LMS</a>
			
				<a class="sidemenu-link sidemenu-lms-link sidemenu-link-txt lms-color sidemenu-icon online-icon" href="/lms/online">オンライン授業情報</a>
			
			<a class="sidemenu-link sidemenu-lms-link sidemenu-link-txt task-color sidemenu-icon task-icon" href="/lms/task">課題・テスト一覧</a>
			<a class="sidemenu-link sidemenu-lms-link sidemenu-link-txt course-search-color sidemenu-icon search-icon" href="/course/search">科目検索</a>
		
		<a class="sidemenu-link sidemenu-lms-link sidemenu-link-txt community-search-color sidemenu-icon search-icon" href="/community/search">コミュニティ</a>
		<br>
		
			<a class="sidemenu-link sidemenu-lms-link sidemenu-link-txt info-color sidemenu-icon info-icon " href="javascript:void(0);" onclick="portalHomeAnchor('#top_information3');">お知らせ</a>
			<a class="sidemenu-link sidemenu-lms-link sidemenu-link-txt questionnaire-color sidemenu-icon questionnaire-icon" href="javascript:void(0);" onclick="portalHomeAnchor('#top_questionnaire');">アンケート</a>
			<a class="sidemenu-link sidemenu-lms-link sidemenu-link-txt notice-color sidemenu-icon notice-icon" href="javascript:void(0);" onclick="portalHomeAnchor('#top_banner');">バナーリンク</a>
			<a class="sidemenu-link sidemenu-lms-link sidemenu-link-txt links-color sidemenu-icon links-icon" href="javascript:void(0);" onclick="portalHomeAnchor('#top_notice');">リンク</a>
			<a class="sidemenu-link sidemenu-lms-link sidemenu-link-txt calendar-color sidemenu-icon calendar-icon" href="javascript:void(0);" onclick="portalHomeAnchor('#top_calendar');">カレンダー</a>
		
		<br>

		
		
		
		
			<div>
</div>
		
	</div>

		<!--右カラム-->
		<div id="pageMain" class="page-main">

			<!--ヘッダ-->
			<header id="global-header" class="global-header">

			<div id="page_head" class="page-head clearfix">
				<div id="sidemenuOpen" class="hamburger-icon sidemenu-open">
					<div class="hamburger-line"></div>
					<div class="hamburger-line"></div>
					<div class="hamburger-line"></div>
				</div>
				<div class="btn-left">
					<ul class="page-head-notification-area clearfix">
						
							<li class="header-information">
								<a href="javascript:void(0)" class="btn-header-info btnControl" id="ctrl_btn_info">
									<span class="header-new-icon"></span>
									<img class="header-img" src="/img/head_icon_info.png"  title="お知らせ" alt="お知らせ">
								</a>
							</li>
						
						
							<li class="header-notification">
								<a href="javascript:void(0)" class="btn-header-info btnControl" id="ctrl_btn_notification">
									<span class="header-new-icon"></span>
									<img class="header-img" src="/img/head_icon_info_bell.png"  title="更新通知" alt="更新通知">
								</a>
							</li>
						
					</ul>
				</div>
				<!-- お知らせ一覧 -->
				
					<ul id="ctrl_menu_info" class="header-control-list control-menu break">
						<li class="header-control-list header-control-color" style="height:auto;">
							<a class="header-control-colomn" data1="146933" data2="202601SU0102631001"
								onclick="InfoDetail(event, this.getAttribute(&#39;data1&#39;), this.getAttribute(&#39;data2&#39;));" style="height:auto;">
								<span class="info_title">人工知能プログラミングの進め方</span>
								<span class="newIcon">new</span>
							</a>
						</li>
						<li class="header-control-list header-control-color" style="height:auto;">
							<a class="header-control-colomn" data1="146763" data2="2026com0012249902"
								onclick="InfoDetail(event, this.getAttribute(&#39;data1&#39;), this.getAttribute(&#39;data2&#39;));" style="height:auto;">
								<span class="info_title">【延長・会場変更】6月16日㈫　須藤元気 氏　特別講演会</span>
								
							</a>
						</li>
						<li class="header-control-list header-control-color" style="height:auto;">
							<a class="header-control-colomn" data1="146827" data2="202601SU0083121001"
								onclick="InfoDetail(event, this.getAttribute(&#39;data1&#39;), this.getAttribute(&#39;data2&#39;));" style="height:auto;">
								<span class="info_title">第８回（No.８）の講義資料（事前配布）について</span>
								
							</a>
						</li>
						<li class="header-control-list header-control-color" style="height:auto;">
							<a class="header-control-colomn" data1="146820" data2="202601SU0083121001"
								onclick="InfoDetail(event, this.getAttribute(&#39;data1&#39;), this.getAttribute(&#39;data2&#39;));" style="height:auto;">
								<span class="info_title">第７回（No.７）の授業動画について</span>
								
							</a>
						</li>
						<li class="header-control-list header-control-color" style="height:auto;">
							<a class="header-control-colomn" data1="146648" data2="202601SU0102001001"
								onclick="InfoDetail(event, this.getAttribute(&#39;data1&#39;), this.getAttribute(&#39;data2&#39;));" style="height:auto;">
								<span class="info_title">[重要]　レポート課題２について</span>
								
							</a>
						</li>
						<li class="header-control-list header-control-color">
							<a class="header-control-colomn" href="/lms/course/information/list">お知らせ一覧へ</a>
						</li>
					</ul>
				
				<!-- 更新通知一覧 -->
				
					<ul id="ctrl_menu_notification" class="header-control-list control-menu break" style="display: none;" >
						<li class="header-control-list header-control-color" style="height:auto;">
							
							
								
								
									<a class="header-control-colomn" href="/updateinfo/transition?idnumber=202601SU0102631001&amp;contentId=146933&amp;module=information&amp;action=add&amp;clickPoint=1&amp;role=STUDENT&amp;url=%2Flms%2Fcourse%3Fidnumber%3D202601SU0102631001&amp;updateInfoId=727157"
										style="height:auto;">・お知らせ(人工知能プログラミングの進め方)が追加されました。(2026/06/15 08:00)</a>
								
							
						</li>
						<li class="header-control-list header-control-color" style="height:auto;">
							
							
								
								
									<a class="header-control-colomn" href="/updateinfo/transition?idnumber=202601SU0084841001&amp;contentId=20071055&amp;module=report&amp;action=submit&amp;clickPoint=1&amp;role=STUDENT&amp;url=%2Flms%2Fcourse%2Freport%2Fsubmission%3Fidnumber%3D202601SU0084841001%26reportId%3D20071055&amp;updateInfoId=726709"
										style="height:auto;">・課題(演習：センサー課題)を提出しました。(2026/06/14 23:53)</a>
								
							
						</li>
						<li class="header-control-list header-control-color" style="height:auto;">
							
							
								
								
									<a class="header-control-colomn" href="/updateinfo/transition?idnumber=202601SU0332821001&amp;contentId=20070520&amp;module=report&amp;action=submit&amp;clickPoint=1&amp;role=STUDENT&amp;url=%2Flms%2Fcourse%2Freport%2Fsubmission%3Fidnumber%3D202601SU0332821001%26reportId%3D20070520&amp;updateInfoId=726736"
										style="height:auto;">・課題(課題（３）)を提出しました。(2026/06/14 23:03)</a>
								
							
						</li>
						<li class="header-control-list header-control-color" style="height:auto;">
							
							
								
								
									<a class="header-control-colomn" href="/updateinfo/transition?idnumber=202601SU0083121001&amp;contentId=20043733&amp;module=question&amp;action=answer&amp;clickPoint=1&amp;role=STUDENT&amp;url=%2Flms%2Fcourse%2Fsurveys%2Ftake%3Fidnumber%3D202601SU0083121001%26surveyId%3D20043733&amp;updateInfoId=727085"
										style="height:auto;">・アンケート(「情報セキュリティ」第１回アンケート)で回答しました。(2026/06/14 22:49)</a>
								
							
						</li>
						<li class="header-control-list header-control-color" style="height:auto;">
							
							
								
								
									<a class="header-control-colomn" href="/updateinfo/transition?idnumber=202601SU0083121001&amp;contentId=146827&amp;module=information&amp;action=add&amp;clickPoint=1&amp;role=STUDENT&amp;url=%2Flms%2Fcourse%3Fidnumber%3D202601SU0083121001&amp;updateInfoId=725535"
										style="height:auto;">・お知らせ(第８回（No.８）の講義資料（事前配布）について)が追加されました。(2026/06/11 22:37)</a>
								
							
						</li>
						<li class="header-control-list header-control-color" style="height:auto;">
							
							
								
								
									<a class="header-control-colomn" href="/updateinfo/transition?idnumber=202601SU0083121001&amp;contentId=146820&amp;module=information&amp;action=add&amp;clickPoint=1&amp;role=STUDENT&amp;url=%2Flms%2Fcourse%3Fidnumber%3D202601SU0083121001&amp;updateInfoId=725469"
										style="height:auto;">・お知らせ(第７回（No.７）の授業動画について)が追加されました。(2026/06/11 19:17)</a>
								
							
						</li>
						<li class="header-control-list header-control-color" style="height:auto;">
							
							
								
								
									<a class="header-control-colomn" href="/updateinfo/transition?idnumber=202601SU0083691001&amp;contentId=20033748&amp;module=test&amp;action=answer&amp;clickPoint=1&amp;role=STUDENT&amp;url=%2Flms%2Fcourse%2Fexamination%2Ftakeresult%3Fidnumber%3D202601SU0083691001%26examinationId%3D20033748&amp;updateInfoId=725251"
										style="height:auto;">・テスト(小テストCV08)で解答しました。(2026/06/11 14:58)</a>
								
							
						</li>
						<li class="header-control-list header-control-color" style="height:auto;">
							
							
								
								
									<a class="header-control-colomn" href="/updateinfo/transition?idnumber=202601SU0083691001&amp;contentId=20033748&amp;module=test&amp;action=add&amp;clickPoint=1&amp;role=STUDENT&amp;url=%2Flms%2Fcourse%2Fexamination%2Ftaketop%3Fidnumber%3D202601SU0083691001%26examinationId%3D20033748&amp;updateInfoId=685222"
										style="height:auto;">・テスト(小テストCV08)が追加されました。(2026/06/11 14:25)</a>
								
							
						</li>
						<li class="header-control-list header-control-color" style="height:auto;">
							
							
								
								
									<a class="header-control-colomn" href="/updateinfo/transition?idnumber=202601SU0084841001&amp;contentId=20071055&amp;module=report&amp;action=update&amp;clickPoint=1&amp;role=STUDENT&amp;url=%2Flms%2Fcourse%2Freport%2Fsubmission%3Fidnumber%3D202601SU0084841001%26reportId%3D20071055&amp;updateInfoId=725038"
										style="height:auto;">・課題(演習：センサー課題)が更新されました。(2026/06/11 12:29)</a>
								
							
						</li>
						<li class="header-control-list header-control-color" style="height:auto;">
							
							
								
								
									<a class="header-control-colomn" href="/updateinfo/transition?idnumber=2026com0012249902&amp;contentId=146763&amp;module=information&amp;action=add&amp;clickPoint=1&amp;role=STUDENT&amp;url=%2Flms%2Fcourse%3Fidnumber%3D2026com0012249902&amp;updateInfoId=724716"
										style="height:auto;">・お知らせ(【延長・会場変更】6月16日㈫　須藤元気 氏　特別講演会)が追加されました。(2026/06/11 08:15)</a>
								
							
						</li>
						<li class="header-control-list header-control-color">
							<a class="header-control-colomn" href="/updateinfo">更新通知一覧へ</a>
						</li>
					</ul>
				
				<div class="page-head-navi">
					<ul class="page-head-navi-unordered-list clearfix">
						<li class="page-head-navi-list">
							<a class="page-head-navi-colomn" href="/common/support/manual" id="link_to_manual"  target="_manual_inquiry_help">Manual</a>
						</li>
						<li class="page-head-navi-list">
							<a class="page-head-navi-colomn" href="/common/support/inquiry" id="link_to_support" target="_manual_inquiry_help">Contacts</a>
						</li>
						<!-- HELP非表示
						<li class="page-head-navi-list">
							<a class="page-head-navi-colomn" href="/common/support/help" id="link_to_help" th:text="#{header.help.label}" target="_manual_inquiry_help"></a>
						</li>
						-->
						<li class="page-head-navi-list">
							<a class="page-head-navi-colomn" href="/common/settings">Settings</a>
						</li>
						<li class="page-head-navi-list">
							<a class="page-head-navi-colomn" href="/logout">Logout</a>
						</li>
					</ul>
				</div>
				<div class="page-head-navi-sp">
					<div class="btn-control btnControl relativeBtn">
						<ul class="control-menu">
							<li class="control-list"><a class="control-menu-colomn" href="/common/support/manual" id="link_to_manual" target="_blank">Manual</a></li>
							<li class="control-list"><a class="control-menu-colomn" href="/common/support/inquiry" id="link_to_support" target="_blank">Contacts</a></li>
							<!--　HELP非表示
							<li class="control-list"><a class="control-menu-colomn" href="/common/support/help" id="link_to_help" th:text="#{header.help.label}" target="_blank"></a></li>
							-->
							<li class="control-list"><a class="control-menu-colomn" href="/common/settings">Settings</a></li>
							<li class="control-list"><a class="control-menu-colomn" href="/logout">Logout</a></li>
						</ul>
					</div>
				</div>
			</div>
		</header>

			<div id="pageContents">

				<div class="page-outline">
					<!-- ログイン情報 -->
					<div>
		<div class="login-view clearfix">
			<div class="login-view-name bold-txt">井﨑　珀斗</div>
		</div>
	</div>
				</div>

				<!--ページコンテンツ-->
				<div id="timetable">

		<div class="timetable-color">
			<div class="timetable-icon"></div>
			<div class="timetable-title timetable-title-txt">時間割</div>
		</div>

		
		<input type="hidden" id="permitStudent" value="true" />
		<input type="hidden" id="viewUserId" value="" />
		

		<form action="/lms/timetable" method="get" id="selectTimetable">

			
			
			<div>
				
				<div class="contents-input-area">
					<div class="contents-exchange-block-inline">
						<input type="radio" id="displayMode1" class="input input-radio displayMode" name="selectDisplayMode"
							value="0" checked="checked" />
						<label for="displayMode1">履修科目一覧</label>
					</div>
					<div class="contents-exchange-block-inline">
						<input type="radio" id="displayMode2" class="input input-radio displayMode" name="selectDisplayMode"
							value="1" />
						<label for="displayMode2">スケジュール</label>
					</div>
				</div>
				<div class="contents-question-template-area timetable-condition-select-area">
					<!-- /* 年度 */ -->
					<div class="input-select-box-area timetable-select-nendo  timetable-selectbox condision-select">
						<select class="input input-select-box timetable-select-nendo timetable-selectbox nendo" id="nendo" name="risyunen">
							<option value="2026"

								selected="selected">2026年度</option>
							<option value="2025">2025年度</option>
							<option value="2024">2024年度</option>
							<option value="2023">2023年度</option>
							<option value="2022">2022年度</option>
							<option value="2021">2021年度</option>
							<option value="2020">2020年度</option>
							<option value="2019">2019年度</option>
							<option value="2018">2018年度</option>
							<option value="2017">2017年度</option>
						</select>
					</div>
					
					<div class="input-select-box-area  timetable-selectbox timetable-select-term timetable-select-margin condision-select">
						<select class="input input-select-box timetable-selectbox timetable-select-term term"
							id="kikanCd" name="kikanCd">
							<option value="10"
								selected="selected">前期</option>
							<option value="20">後期</option>
						</select>
					</div>
					
					<div class="input-select-box-area timetable-selectbox timetable-select-weekday timetable-select-margin pc-contents-hidden">
						<select class="input input-select-box timetable-selectbox timetable-select-weekday" id="timetableSelectYobiForSmart" name="yobiCd">
							<option value="1" selected="selected">月</option>
							<option value="2">火</option>
							<option value="3">水</option>
							<option value="4">木</option>
							<option value="5">金</option>
							<option value="6">土</option>
						</select>
					</div>
				</div>

				
				<div class="contents-question-template-area timetable-condition-select-area">
					<div class="selected-display-date">前期:2026年04月01日 ～ 2026年09月30日</div>
				</div>
				
				
					<div class="contents-question-template-area timetable-condition-select-area">
						<div class="selected-display-date">１Q:2026年04月11日 ～ 2026年06月04日</div>
					</div>
					<div class="contents-question-template-area timetable-condition-select-area">
						<div class="selected-display-date">２Q:2026年06月06日 ～ 2026年07月26日</div>
					</div>
				

				<div class="timetable-icon-area contents-question-template-area">
					<!-- 仮登録アイコン -->
					
					<!-- 履修者名簿アイコン -->
					
					 
					 <div id="roomMessage" class="timetable-explanation-icon explanation-txt room-message-txt"></div>
				</div>
			</div>

			
			<div class="div-table contents-detail">
				
				<div class="div-table-body div-table-header">
					<div class="div-table-colomn-period div-table-colomn-period-color">時限</div>
					<div class="div-table-head div-table-head-color yobi-color1 1-yobicol">月</div>
					<div class="div-table-head div-table-head-color yobi-color2 2-yobicol">火</div>
					<div class="div-table-head div-table-head-color yobi-color3 3-yobicol">水</div>
					<div class="div-table-head div-table-head-color yobi-color4 4-yobicol">木</div>
					<div class="div-table-head div-table-head-color yobi-color5 5-yobicol">金</div>
					<div class="div-table-head div-table-head-color yobi-color6 6-yobicol">土</div>
				</div>
				<div class="div-table-data-row">
					
					<div class="div-table-colomn-period div-table-colomn-period-color">１限</div>
					
					<div class="div-table-cell 1-yobicol" >
						<div class="clearfix permit-student">
							<div class="timetable-course-top-btn bold-txt divTableCellHeader 
									
									"  id="202601SU0083121001">情報セキュリティ</div>
							<div class="div-table-cell-detail">
								<div data-toggle="tooltip" data-html="true" title="教室棟405教室">
										
									<span>大久保　英樹</span>
									
									 <div>【教室】</div>
								</div>
								<div class="div-table-cell-info">
									<div>
										
										
									</div>
								</div>
							</div>
						</div>
					</div>
					
					<div class="div-table-cell 2-yobicol" >
						
					</div>
					
					<div class="div-table-cell 3-yobicol" >
						
					</div>
					
					<div class="div-table-cell 4-yobicol" >
						
					</div>
					
					<div class="div-table-cell 5-yobicol" >
						
					</div>
					
					<div class="div-table-cell 6-yobicol" >
						
					</div>
				</div>
				<div class="div-table-data-row">
					
					<div class="div-table-colomn-period div-table-colomn-period-color">２限</div>
					
					<div class="div-table-cell 1-yobicol" >
						
					</div>
					
					<div class="div-table-cell 2-yobicol" >
						<div class="clearfix permit-student">
							<div class="timetable-course-top-btn bold-txt divTableCellHeader 
									
									"  id="202601SU0332821001">ソフトウェア工学</div>
							<div class="div-table-cell-detail">
								<div data-toggle="tooltip" data-html="true" title="教室棟405教室">
										
									<span>中丸　智貴</span>
									
									 <div>【教室】</div>
								</div>
								<div class="div-table-cell-info">
									<div>
										
										
									</div>
								</div>
							</div>
						</div>
					</div>
					
					<div class="div-table-cell 3-yobicol" >
						
					</div>
					
					<div class="div-table-cell 4-yobicol" >
						<div class="clearfix permit-student">
							<div class="timetable-course-top-btn bold-txt divTableCellHeader 
									
									"  id="202601SU0084841001">組込みシステム</div>
							<div class="div-table-cell-detail">
								<div data-toggle="tooltip" data-html="true" title="教室棟605教室(PC),教室棟604教室(PC),教室棟405教室">
										
									<span>菅谷　みどり</span>
									
									 <div>【教室】</div>
								</div>
								<div class="div-table-cell-info">
									<div>
										
										
									</div>
								</div>
							</div>
						</div>
					</div>
					
					<div class="div-table-cell 5-yobicol" >
						
					</div>
					
					<div class="div-table-cell 6-yobicol" >
						
					</div>
				</div>
				<div class="div-table-data-row">
					
					<div class="div-table-colomn-period div-table-colomn-period-color">３限</div>
					
					<div class="div-table-cell 1-yobicol" >
						<div class="clearfix permit-student">
							<div class="timetable-course-top-btn bold-txt divTableCellHeader 
									out-of-term-course
									"  id="202601SU0102001001">Java応用プログラミング(１Q)</div>
							<div class="div-table-cell-detail out-of-term-course">
								<div data-toggle="tooltip" data-html="true" title="教室棟608教室(PC),教室棟609教室(PC)">
										
									<span>パトハック　サーサク</span>
									
									 <div>【教室】</div>
								</div>
								<div class="div-table-cell-info">
									<div>
										
										
									</div>
								</div>
							</div>
						</div>
						<div class="clearfix permit-student">
							<div class="timetable-course-top-btn bold-txt divTableCellHeader plural
									
									"  id="202601SU0102631001">人工知能プログラミング(２Q)</div>
							<div class="div-table-cell-detail">
								<div data-toggle="tooltip" data-html="true" title="教室棟608教室(PC),教室棟609教室(PC)">
										
									<span>渡部　昌平</span>
									
									 <div>【教室】</div>
								</div>
								<div class="div-table-cell-info">
									<div>
										
										
									</div>
								</div>
							</div>
						</div>
					</div>
					
					<div class="div-table-cell 2-yobicol" >
						<div class="clearfix permit-student">
							<div class="timetable-course-top-btn bold-txt divTableCellHeader 
									
									"  id="202601SU0086181001">ソフトウェア開発演習</div>
							<div class="div-table-cell-detail">
								<div data-toggle="tooltip" data-html="true" title="教室棟405教室">
										
									<span>福田　浩章</span><span>,  中丸　智貴</span>
									
									 <div>【教室】</div>
								</div>
								<div class="div-table-cell-info">
									<div>
										
										
									</div>
								</div>
							</div>
						</div>
					</div>
					
					<div class="div-table-cell 3-yobicol" >
						<div class="clearfix permit-student">
							<div class="timetable-course-top-btn bold-txt divTableCellHeader 
									
									"  id="202601SU0084321001">人工知能</div>
							<div class="div-table-cell-detail">
								<div data-toggle="tooltip" data-html="true" title="教室棟302教室,交流棟501教室">
										
									<span>渡部　昌平</span>
									
									 <div>【教室】</div>
								</div>
								<div class="div-table-cell-info">
									<div>
										
										
									</div>
								</div>
							</div>
						</div>
					</div>
					
					<div class="div-table-cell 4-yobicol" >
						<div class="clearfix permit-student">
							<div class="timetable-course-top-btn bold-txt divTableCellHeader 
									
									"  id="202601SU0083691001">コンピュータビジョン</div>
							<div class="div-table-cell-detail">
								<div data-toggle="tooltip" data-html="true" title="教室棟405教室,教室棟603教室">
										
									<span>井尻　敬</span>
									
									 <div>【教室】</div>
								</div>
								<div class="div-table-cell-info">
									<div>
										
										
									</div>
								</div>
							</div>
						</div>
					</div>
					
					<div class="div-table-cell 5-yobicol" >
						
					</div>
					
					<div class="div-table-cell 6-yobicol" >
						
					</div>
				</div>
				<div class="div-table-data-row">
					
					<div class="div-table-colomn-period div-table-colomn-period-color">４限</div>
					
					<div class="div-table-cell 1-yobicol" >
						<div class="clearfix permit-student">
							<div class="timetable-course-top-btn bold-txt divTableCellHeader 
									out-of-term-course
									"  id="202601SU0102001001">Java応用プログラミング(１Q)</div>
							<div class="div-table-cell-detail out-of-term-course">
								<div data-toggle="tooltip" data-html="true" title="教室棟608教室(PC),教室棟609教室(PC)">
										
									<span>パトハック　サーサク</span>
									
									 <div>【教室】</div>
								</div>
								<div class="div-table-cell-info">
									<div>
										
										
									</div>
								</div>
							</div>
						</div>
						<div class="clearfix permit-student">
							<div class="timetable-course-top-btn bold-txt divTableCellHeader plural
									
									"  id="202601SU0102631001">人工知能プログラミング(２Q)</div>
							<div class="div-table-cell-detail">
								<div data-toggle="tooltip" data-html="true" title="教室棟608教室(PC),教室棟609教室(PC)">
										
									<span>渡部　昌平</span>
									
									 <div>【教室】</div>
								</div>
								<div class="div-table-cell-info">
									<div>
										
										
									</div>
								</div>
							</div>
						</div>
					</div>
					
					<div class="div-table-cell 2-yobicol" >
						<div class="clearfix permit-student">
							<div class="timetable-course-top-btn bold-txt divTableCellHeader 
									
									"  id="202601SU0086181001">ソフトウェア開発演習</div>
							<div class="div-table-cell-detail">
								<div data-toggle="tooltip" data-html="true" title="教室棟405教室">
										
									<span>福田　浩章</span><span>,  中丸　智貴</span>
									
									 <div>【教室】</div>
								</div>
								<div class="div-table-cell-info">
									<div>
										
										
									</div>
								</div>
							</div>
						</div>
					</div>
					
					<div class="div-table-cell 3-yobicol" >
						<div class="clearfix permit-student">
							<div class="timetable-course-top-btn bold-txt divTableCellHeader 
									
									"  id="202601SU0092911001">データ解析法</div>
							<div class="div-table-cell-detail">
								<div data-toggle="tooltip" data-html="true" title="教室棟302教室">
										
									<span>木村　昌臣</span>
									
									 <div>【教室】</div>
								</div>
								<div class="div-table-cell-info">
									<div>
										
										
									</div>
								</div>
							</div>
						</div>
					</div>
					
					<div class="div-table-cell 4-yobicol" >
						
					</div>
					
					<div class="div-table-cell 5-yobicol" >
						
					</div>
					
					<div class="div-table-cell 6-yobicol" >
						
					</div>
				</div>
				<div class="div-table-data-row">
					
					<div class="div-table-colomn-period div-table-colomn-period-color">５限</div>
					
					<div class="div-table-cell 1-yobicol" >
						
					</div>
					
					<div class="div-table-cell 2-yobicol" >
						
					</div>
					
					<div class="div-table-cell 3-yobicol" >
						
					</div>
					
					<div class="div-table-cell 4-yobicol" >
						
					</div>
					
					<div class="div-table-cell 5-yobicol" >
						
					</div>
					
					<div class="div-table-cell 6-yobicol" >
						
					</div>
				</div>
				<div class="div-table-data-row">
					
					<div class="div-table-colomn-period div-table-colomn-period-color">６限</div>
					
					<div class="div-table-cell 1-yobicol" >
						
					</div>
					
					<div class="div-table-cell 2-yobicol" >
						
					</div>
					
					<div class="div-table-cell 3-yobicol" >
						
					</div>
					
					<div class="div-table-cell 4-yobicol" >
						
					</div>
					
					<div class="div-table-cell 5-yobicol" >
						
					</div>
					
					<div class="div-table-cell 6-yobicol" >
						
					</div>
				</div>
				<div class="div-table-data-row">
					
					<div class="div-table-colomn-period div-table-colomn-period-color">７限</div>
					
					<div class="div-table-cell 1-yobicol" >
						
					</div>
					
					<div class="div-table-cell 2-yobicol" >
						
					</div>
					
					<div class="div-table-cell 3-yobicol" >
						
					</div>
					
					<div class="div-table-cell 4-yobicol" >
						
					</div>
					
					<div class="div-table-cell 5-yobicol" >
						
					</div>
					
					<div class="div-table-cell 6-yobicol" >
						
					</div>
				</div>
			</div>
			<div class="timetable-update highlight-txt"></div>

			<!-- 集中コース等 -->
			<div class="div-table timetable-other-course">
				<div class="div-table-body">
					<div class="div-table-row" >
						<div class="timetable-other-course-header div-table-colomn-period-color">
							<span class="bold-txt">その他（曜日時限不定など）</span>
						</div>
						<div class="div-table-cell">
							<div class="div-table-cell-row permit-student">
								<div class="timetable-course-top-btn bold-txt 
									"
									id="202601SU0176241001">卒業研究1</div>
								<div class="div-table-cell-detail">
									
									<span>菅谷　みどり</span><span>,  福田　浩章</span><span>,  木村　昌臣</span><span>,  松原　良太</span><span>,  篠埜　功</span><span>,  石﨑　聡之</span><span>,  杉本　徹</span><span>,  井尻　敬</span><span>,  真鍋　宏幸</span><span>,  新熊　亮一</span><span>,  渡部　昌平</span><span>,  金尾　太郎</span><span>,  楊　鯤昊</span><span>,  木下　雄一朗</span><span>,  中丸　智貴</span>
									
									
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>

			<!-- 編集可能なコース -->
			

			<!-- 履修コース -->
			
		</form>

		<form action="/lms/timetable" method="get" id="todaysTimetable">
			
			<input type="hidden" name="selectToday" value="true" />
		</form>

		<div id="roomNoticePc" hidden="true">【教室】にカーソルを合わせると教室名が表示されます。</div>
		<div id="roomNoticeMobile" hidden="true">【教室】を長押しすると教室名が表示されます。</div>
	</div>

				<!--ダイレクトリンク-->
				
			</div>

			<!--フッタ-->
			<div id="page_foot" class="page-foot">
		<div class="page-foot-contents clearfix">
			<a target="_blank" class="page-foot-logo" href="https://www.shibaura-it.ac.jp">
				<img src="/footerlogo">
			</a>
			<div class="page-foot-link">
				<ul class="page-foot-link-contents">
					<li class="page-foot-link-list"><a class="page-foot-link-colomn" target="_blank" href="https://www.shibaura-it.ac.jp">このサイトについて</a></li>
					<li class="page-foot-link-list"><a class="page-foot-link-colomn" target="_blank" href="https://www.shibaura-it.ac.jp">プライバシーポリシー</a></li>
					<li class="page-foot-link-list"></li>
				</ul>
			</div>
		</div>
		<div class="page-top-btn">Top</div>
	</div>
		</div>
		
		<div id="progressMessage" hidden="true">データ処理中です</div>
	</div>

	<!-- お知らせ詳細 -->
	<div>
		<form action="/lms/course/information/list" method="post" id="informationDtl"><input type="hidden" name="_csrf" value="b26ade93-dc47-49e0-adb0-6799be83d8e1"/>
			<input type="hidden" id="viewPage" name="viewPage" value="1" />
			<input type="hidden" id="viewkind" name="viewkind" value="9" />
			<input type="hidden" id="informationId" name="informationId" />
		</form>
		<div id="info_detail_view2" hidden="true"></div>
	</div>

</body>
</html>
    ''';

    // 2. HTMLをパース
    html_dom.Document document = html_parser.parse(mockHtmlString);

    // 3. 科目名が書かれているクラス（.timetable-course-top-btn）を狙い撃ちで全取得
    List<html_dom.Element> elements = document.querySelectorAll('.timetable-course-top-btn');

    for (var element in elements) {
      // テキスト部分（科目名）を取得して前後の空白を削除
      String name = element.text.trim();
      
      if (name.isNotEmpty) {
        subjectNames.add(name);
      }
    }

    // 4. 結果の確認用プリント
    print('--- 抽出された科目名一覧 ---');
    for (var subject in subjectNames) {
      print(subject);
    }
  }
}