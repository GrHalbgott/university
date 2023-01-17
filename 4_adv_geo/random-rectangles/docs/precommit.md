# Pre-commit Hooks

## Git hooks

- hooks are scripts
- hooks are triggered by an event
- hooks are located in the `.git/hooks` directory
- hooks are local

### Workflow

```bash
touch file.txt
git add file.txt
# hooks will be triggered
git commit -m "my commit message"
```

## pre-commit

> A framework for managing and maintaining pre-commit hooks ([Website](https://pre-commit.com/))

### Installation

```bash
pip install pre-commit
# Or
conda install -c conda-forge pre-commit
# Or
poetry add --dev pre-commit
```

### Setup

- create a file named `.pre-commit-config.yaml`
- write down the configuration:

```yaml
repos:
-   repo: https://github.com/psf/black
    rev: 21.12b0
    hooks:
    -   id: black
```

### Usage

```bash
# Run once
pre-commit install
# Do your work
```

## Aknowledgements

Thanks to Mathias Schaub for creating this introduction to pre-commit.

## Resources

- [pre-commit documentation](https://pre-commit.com/)
- [black integration](https://black.readthedocs.io/en/stable/integrations/source_version_control.html?highlight=pre-commit#version-control-integration)
- [flake8 integration](https://flake8.pycqa.org/en/latest/user/using-hooks.html?highlight=pre-commit)
- [isort integration](https://pycqa.github.io/isort/docs/configuration/pre-commit.html)
- [OQT pre-commit configuration](https://github.com/GIScience/ohsome-quality-analyst/blob/main/.pre-commit-config.yaml)
