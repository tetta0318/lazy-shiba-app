// // アクセス可能な状態のScombZのHTMLからタスクに必要な情報を取り出すためのコードです。

// import 'package:html/parser.dart' as html_parser;
// import 'package:dio/dio.dart' as dio;
// import 'package:html/dom.dart' as html_dom;

// class Assignment{
//   final int taskId;
//   final int subjectId;
//   final String taskName;
//   final String subjectName;
//   final String deadline;
//   final String submissionURL;
//   final int taskresponse;
//   final int taskstatus;
//   Assignment({
//     required this.taskId,
//     this.subjectId = 0,
//     required this.taskName,
//     required this.subjectName,
//     required this.deadline,
//     required this.submissionURL,
//     this.taskresponse = 0,
//     this.taskstatus = 0,
//   });
// }

// class tasks_scraping{

//   final dio.Dio taskDio = dio.Dio();
//   List<Assignment> assignmentList = [];

//   Future <void> getTasks() async {
    
//     dio.Response response;
//     // HTMLをString型で取得する
//     try {
//       response = await taskDio.get('https://scombz.shibaura-it.ac.jp/lms/task');
//       final String htmlString = response.data.toString();
//       // 取ってきたStringをdocmentオブジェクトに変換する
//       html_dom.Document document = html_parser.parse(htmlString);
//       // タスクの情報を抜き取る
//       List<html_dom.Element> taskElements = document.querySelectorAll('.result_list_line');
//       int idCounter = 1;
//       for(final html_dom.Element row in taskElements){
//           // --- 科目名の取得 ---
//         final html_dom.Element? courseElement = row.querySelector('.tasklist-course');
//         final String subjectName = courseElement?.text.trim() ?? '科目不明';

//         // --- 課題名と提出URLの取得 ---
//         // 「tasklist-title」クラスの中にある「a」タグをピンポイントで探す
//         final html_dom.Element? anchor = row.querySelector('.tasklist-title a');
//         final String taskName = anchor?.text.trim() ?? 'タイトルなし';
//         final String submissionURL = anchor?.attributes['href'] ?? '';

//         // --- 提出期限の取得 --- 
//         // class="deadline" を持っているspanタグを直接狙い撃ち
//         final html_dom.Element? deadlineElement = row.querySelector('.deadline');
//         final String deadline = deadlineElement?.text.trim() ?? '';

//         // クラスに格納
//         final assignment = Assignment(
//           taskId: idCounter++,
//           taskName: taskName,
//           subjectName: subjectName,
//           deadline: deadline,
//           submissionURL: submissionURL,
//         );

//         assignmentList.add(assignment);
//         }
// これ以降の処理はインタフェースが出来上がったらデータベース値を渡すだけに変更
//         print('\n=========================================');
//         print('【解析完了】取得件数: \${assignmentList.length} 件');
//         print('=========================================');

//       for (final assignment in assignmentList) {
//         print('【ID】     \${assignment.taskId}');
//         print('【科目名】 \${assignment.subjectName}');
//         print('【課題名】 \${assignment.taskName}');
//         print('|__ [締切] \${assignment.deadline}');
//         print('|__ [URL]  \${assignment.submissionURL}');
//         print('-----------------------------------------');
//       }
//       print('=========================================\n');
//     } on Exception catch (e) {
//   // TODO
//       print('HTMLの取得に失敗しました: $e');
//     }

//   }
// }


// テスト用の擬似HTMLを用いて、スクレイピングのロジックを完璧に動かすコードです。
import 'package:html/parser.dart' as html_parser;
import 'package:dio/dio.dart' as dio;
import 'package:html/dom.dart' as html_dom;

class Assignment {
  final int taskId;
  final String subjectId; // 文字列や記号が混ざる可能性を考慮してStringに変更
  final String taskName;
  final String subjectName;
  final String deadline;
  final String submissionURL;
  final int taskresponse;
  final int taskstatus;

  Assignment({
    required this.taskId,
    this.subjectId = '',
    required this.taskName,
    required this.subjectName,
    required this.deadline,
    required this.submissionURL,
    this.taskresponse = 0,
    this.taskstatus = 0,
  });
}

class TasksScraping {
  final dio.Dio taskDio = dio.Dio();
  List<Assignment> assignmentList = [];

  Future<void> getTasks() async {
    assignmentList.clear();

    // テスト用の擬似HTML（一部省略）
    final String mockHtmlString =r'''
    <!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>課題・テスト一覧</title>
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
<link href="/css/common.css" rel="stylesheet"/>
<link href="/course/css/tasklist.css" rel="stylesheet">
</link>
<script type="text/javascript" src="/course/js/task_list.js"></script>
<script src="/js/jquery.magnific-popup.min.js"></script>
<script type="text/javascript" src="../js/jquery.dependent-selects.js"></script>
<script src="/js/quill.min.js"></script>
<script src="/js/quillUtil.js"></script>
<script>
$(document).ready(function() {
	// ソート
	CommonUtil.addOnLoad(function() {
		pageSorter("taskList", "sortable");
	}, "task");
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
				<div>
	<form id="onlineCourseForm">
		<div class="course-header">
			<div class="contents-title">
				<div class="contents-title-txt">課題・テスト一覧</div>
			</div>
		</div>
		<div class="block clearfix">
			
			<div class="new-design-top-subblock-title new-design-subblock-title">
				<div>未提出の課題・テスト一覧</div>
			</div>
			
			<div class="contents-list" id="task">
				<div class="contents-detail">
					
					<div class="contents-list result_list " id="taskList">
						
						<div class="result_list_tag contents-header-txt" id="hiddenTitle">
							<div class="tasklist-course bold-txt sortable down sortmark" id="course">
								<span>科目名</span>
							</div>
							<div class="tasklist-contents bold-txt sortable down sortmark" id="contents">
								<span>コンテンツ</span>
							</div>
							<div class="tasklist-title bold-txt">タイトル</div>
							<div class="tasklist-deadline bold-txt sortable up sortmark" id="deadline">
								<span>期限</span>
							</div>

						</div>

						<div class="result_list_content sortTaskParent">
							<div class="result_list_line  contents-display-flex contents-display-flex-exchange-sp sortTaskBlock">
								
								

								
								
									
									<div class="tasklist-course break course">Java応用プログラミング</div>
									
									<div class="tasklist-contents answer-test online-mobile-hide contents">
										<a href="/lms/course/report/submission?idnumber=202601SU0102001001&amp;reportId=20071219">課題</a>
									</div>
									
									<div class="tasklist-title answer-test break online-mobile-hide">
										<a href="/lms/course/report/submission?idnumber=202601SU0102001001&amp;reportId=20071219">レポート課題２</a>
									</div>
									
									<div class = "online-display-hide">
										
										<div class="tasklist-contents answer-test">
											<a href="/lms/course/report/submission?idnumber=202601SU0102001001&amp;reportId=20071219">課題</a>
										</div>
										
										<div class="tasklist-title answer-test break">
											<a href="/lms/course/report/submission?idnumber=202601SU0102001001&amp;reportId=20071219">レポート課題２</a>
										</div>
									</div>
									
									<div class="tasklist-deadline ">
										<span class="tasklist-mobile-deadline">期限：</span>
										<span class="tasklist-mobile-width-deadline deadline">2026/07/03 23:59:00</span>
									</div>
								
							</div>
						</div>
					</div>
				</div>
				
			</div>
		</div>
	</form>
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

    try {
      html_dom.Document document = html_parser.parse(mockHtmlString);
      List<html_dom.Element> taskElements = document.querySelectorAll('.result_list_line');
      int fallbackIdCounter = 1;

      for (final html_dom.Element row in taskElements) {
        // --- 科目名の取得 ---
        final html_dom.Element? courseElement = row.querySelector('.tasklist-course');
        final String subjectName = courseElement?.text.trim() ?? '科目不明';

        // --- 課題名と提出URLの取得 ---
        final html_dom.Element? anchor = row.querySelector('.tasklist-title a');
        final String taskName = anchor?.text.trim() ?? 'タイトルなし';
        final String submissionURL = anchor?.attributes['href'] ?? '';

        // --- URLから各IDの抽出ロジック ---
        int taskId = fallbackIdCounter++;
        String subjectId = '';

        if (submissionURL.isNotEmpty) {
          try {
            final Uri uri = Uri.parse('https://example.com$submissionURL');
            final String? reportId = uri.queryParameters['reportId'];
            final String? idnumber = uri.queryParameters['idnumber'];

            if (reportId != null) {
              taskId = int.tryParse(reportId) ?? taskId;
            }
            if (idnumber != null) {
              subjectId = idnumber;
            }
          } catch (_) {
            // パース失敗時はデフォルト値
          }
        }

        // --- 提出期限の取得 ---
        final html_dom.Element? deadlineElement = row.querySelector('.deadline');
        final String deadline = deadlineElement?.text.trim() ?? '';

        final assignment = Assignment(
          taskId: taskId,
          subjectId: subjectId,
          taskName: taskName,
          subjectName: subjectName,
          deadline: deadline,
          submissionURL: submissionURL,
        );

        assignmentList.add(assignment);
      }
      
      print('取得成功: ${assignmentList.length} 件の課題を追加しました。');
    } on Exception catch (e) {
      print('HTMLの取得・解析に失敗しました: $e');
    }
  }
}
