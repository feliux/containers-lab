import setuptools

setuptools.setup(
    name="helloworld",
    version="0.0.1",
    author="Your Name",
    author_email="your_email@example.com",
    description="A small example package",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
)
