<?
/*
  HtmlParser(
   $code,	html ��� ��� ��� �����, �� ������ ������ ���� � $isfile ���������� 1
		the html code or file name. In second case you need set $isfile to 1

   $grammar,	������������� ���������� - ��������� �� ������
		precompiled grammar - the pointer to array

   $dataname,	�������� ������, ����� ��������� ������
		name of the data, you can leave it empty

   $isfile=0	���������� �������� �� $code ������ ����� ��� ������� ����
		It is flag, which define state of $code, if it's 0 then $code is HTML code, if 1 then $code is filename
  )


  ������ ������ ������ ����� ����� ���������� � common.inc
  � ������� GetPageSrc
  example of the walking through tag tree, you can to see it in the
  common.inc in function GetPageSrc

  ������ ����� �������� ��������� �������:
  Tag tree consists of

  tagarray(
    "contentpos"=>value  ����� ��������� � �����-1, ��������� ���������� � ����
			number of elements in branch. Numeration begins from 0 as in C language
    "0"=>array(
           "type"=>"tag|text|comment",
           "data"=>"text"|array(
				"name"=>"tagname"
				"type"=>"open|close"
                          ),
  	   "pars"=>array( � ����� ���� close � ���� type=text ����� ���������� �����������
			  if type=text or close then pars collection is absent

	   	        "parname"=>array(
		      		  "quot"=>"|\"|'" ��� �������
						  quot type
			          "value"=>value  �������� ��������� ����
						  parameter value
			          "single"=>""	 ���� ���� ������ �������� ��� �������� (�������� disable|enabled|checked � �.�.)
						  if it exists then parameter hav't value like disable|enabled|checked etc.
			          ),
 		   	 .....
   	           ),
           "xmlclose"=>"0|1",  ��� �������� XML Style ��� ���
				if it exists then tag has xml style close <tagname ... />
	   "content"=>tagarray(....)  ���� ���� ������ � ���� ���� �������� ������ �����
				if it exists then tag includes the own branch of tags
   	 ),
    .....
  )

*/
include("common.inc");
include("htmlparser.inc");
$p=new HtmlParser("test.html",unserialize(Read_File("htmlgrammar.cmp")),"test.html",1);
$p->Parse();
$src="";
GetPageSrc(&$p->content,&$src);
print $src;
print "<br><h1>������ �����|Tag tree.</h1>";
PrintArray(&$p->content);
?>