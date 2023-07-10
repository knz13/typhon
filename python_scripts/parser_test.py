import pytest
from cpp_parser import CPPParser

def test_remove_comments():
    text_with_comments = """// This is a single line comment
    /* This is a
    multiline comment */
    int a = 0; // Another single line comment
    """
    expected_output = """
    int a = 0; 
    """
    assert CPPParser.remove_comments(text_with_comments).strip() == expected_output.strip()

def test_remove_content_between_angle_brackets():
    text_with_angle_brackets = "vector<int>"
    expected_output = "vector"
    assert CPPParser.remove_content_between_angle_brackets(text_with_angle_brackets) == expected_output

def test_extract_base_classes():
    file_content = """
    class Derived : public Base1, protected Base2 {
    };
    """
    class_name = "Derived"
    expected_output = ['Base1', 'Base2']
    assert set(CPPParser.extract_base_classes(file_content, class_name)) == set(expected_output)

def test_extract_variable_names():
    code = """
    int a;
    std::string str;
    """
    class_name = "Test"
    expected_output = ['a', 'str']
    assert set(CPPParser.extract_variable_names(code, class_name)) == set(expected_output)

def test_complete():
    
    with open("cpp_library/src/prefab/defaults/cube.h",'r') as f:
        a = f.read()
    print(CPPParser.get_classes_properties(a))
    assert {"a":1} == {}