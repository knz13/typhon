import re
from typing import Dict, List, Tuple

class CPPParser:

    @staticmethod
    def remove_comments(text: str) -> str:
        text = re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)
        text = re.sub(r'//.*?\n', '', text)
        return text

    @staticmethod
    def remove_content_between_angle_brackets(input: str) -> str:
        pattern = re.compile(r'<[^<>]*>', flags=re.MULTILINE | re.DOTALL)
        while True:
            output = pattern.sub('', input)
            if output == input:
                break
            input = output
        return output

    @staticmethod
    def extract_base_classes(file_content: str, class_name: str) -> List[str]:
        pattern = re.compile(rf'class\s+{class_name}\s*:\s*([\s\S]*?)\{{', re.I)
        match = pattern.search(file_content)
        if match is None:
            return []
        
        base_classes_str = match.group(1)
        if base_classes_str is None:
            return []

        base_classes_str = CPPParser.remove_content_between_angle_brackets(base_classes_str)
        base_classes = re.split(r'\s*,\s*', base_classes_str)

        class_name_pattern = re.compile(r'\b(?:public\s+|private\s+|protected\s+)?([\w:]+)\b')
        return [class_name_pattern.search(base_class).group(1) if class_name_pattern.search(base_class) else "" for base_class in base_classes]

    @staticmethod
    def get_classes_properties(text: str) -> Dict[str, Dict[str, List[str]]]:
        text = CPPParser.remove_comments(text)

        classes_text = {}
        classes_inheritance = {}
        class_names = []

        class_name_exp = re.compile(r'class .*? {')
        for match in class_name_exp.finditer(text):
            class_names.append((text[match.start() + 6:].split(' ')[0], text[match.start():].find("{") + match.start() - 1))

        class_name_exp = re.compile(r'class .*? :')
        for match in class_name_exp.finditer(text):
            class_names.append((text[match.start() + 6:].split(' ')[0], text[match.start():].find("{") + match.start() - 1))

        class_names = list(set(class_names))
        class_names.sort(key=lambda x: x[1])

        for class_name in [item[0] for item in class_names]:
            classes_inheritance[class_name] = CPPParser.extract_base_classes(text, class_name)

        # Extracting class text
        for i in range(len(class_names)):
            class_name = class_names[i][0]
            class_start = class_names[i][1]

            if i == len(class_names) - 1:
                end_position = len(text) - 1
            else:
                end_position = class_names[i + 1][1]

            class_text = text[class_start + 1:end_position]
            classes_text[class_name] = class_text

        # Extracting class variables
        classes_variables = CPPParser.extract_variable_from_classes_text(classes_text)

        # Constructing final map
        final_map = {}
        for class_name in classes_text:
            final_map[class_name] = {
                "variables": classes_variables[class_name],
                "class_text": classes_text[class_name],
                "inheritance": classes_inheritance[class_name]
            }

        return final_map

    @staticmethod
    def extract_variable_from_classes_text(classes: Dict[str, str]) -> Dict[str, List[str]]:
        class_variables = {}

        for class_name, class_text in classes.items():
            variables = []

            class_text = class_text.replace('\n', '')
            class_text = re.sub(r'friend.*?;', '', class_text)

            function_impls = []
            stack = 0
            start = -1
            for i in range(1, len(class_text) - 1):
                if class_text[i] == '{':
                    if stack == 0:
                        start = i
                    stack += 1
                elif class_text[i] == '}':
                    stack -= 1
                    if stack == 0 and start != -1:
                        function_impls.append(class_text[start:i + 1])
                        start = -1

            for function_impl in function_impls:
                class_text = class_text.replace(function_impl, ';')

            class_text = ('-' * 100) + '\n\n' + class_text + ' ' + class_name + '\n\n' + ('-' * 100)
            variables = CPPParser.extract_variable_names(class_text, class_name)
            class_variables[class_name] = variables

        return class_variables

    @staticmethod
    def extract_variable_names(code: str, name_of_class: str) -> List[str]:
        variable_names = []

        code = re.sub(r'//.*', '', code)
        statements = re.split(r';|(?<!:):(?!:)', code)

        for statement in statements:
            statement = statement.strip()

            if not statement:
                continue

            if any(keyword in statement for keyword in ['static', 'public', 'private', 'protected', 'override']):
                continue

            statement = statement.replace('::', '')

            if f" {name_of_class}" in statement:
                continue

            name = ''
            function_match = re.search(r'\w+\s+(\w+)\s*\(', statement)
            if function_match:
                name = function_match.group(1)
            else:
                variable_match = re.search(r'(?:[\w:]+(?:<[^>]*>)?|(?:\w+::)*\w+)(?:\s*[\*&]+)?(?:\s*\w+)?\s+([\w]+)', statement)
                if variable_match:
                    name = variable_match.group(1)

            if not name:
                continue

            if '(' in statement[statement.index(name):] and '=' not in statement:
                continue

            variable_names.append(name)

        return variable_names