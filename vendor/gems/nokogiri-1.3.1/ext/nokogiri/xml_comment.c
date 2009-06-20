#include <xml_comment.h>

/*
 * call-seq:
 *  new(document, content)
 *
 * Create a new Comment element on the +document+ with +content+
 */
static VALUE new(int argc, VALUE *argv, VALUE klass)
{
  xmlDocPtr xml_doc;
  VALUE document;
  VALUE content;
  VALUE rest;

  rb_scan_args(argc, argv, "2*", &document, &content, &rest);

  Data_Get_Struct(document, xmlDoc, xml_doc);

  xmlNodePtr node = xmlNewDocComment(
      xml_doc,
      (const xmlChar *)StringValuePtr(content)
  );

  VALUE rb_node = Nokogiri_wrap_xml_node(klass, node);
  rb_funcall2(rb_node, rb_intern("initialize"), argc, argv);

  NOKOGIRI_ROOT_NODE(node);

  if(rb_block_given_p()) rb_yield(rb_node);

  return rb_node;
}

VALUE cNokogiriXmlComment;
void init_xml_comment()
{
  VALUE nokogiri = rb_define_module("Nokogiri");
  VALUE xml = rb_define_module_under(nokogiri, "XML");
  VALUE node = rb_define_class_under(xml, "Node", rb_cObject);

  /*
   * Comment represents a comment node in an xml document.
   */
  VALUE klass = rb_define_class_under(xml, "Comment", node);


  cNokogiriXmlComment = klass;

  rb_define_singleton_method(klass, "new", new, -1);
}
