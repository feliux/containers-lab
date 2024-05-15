import numpy as np
from scipy import signal as sp
import matplotlib.pylab as plt
import scipy.signal as signal
import scipy.stats as stats
import streamlit as st


def u(amplitud, t):
    """Función escalón unitario

    Args:
        amplitud (int): Amplitud del escalon
        t (list): Lista de tiempo

    Returns:
        list: Lista de valores
    """
    return amplitud*np.piecewise(t, [t < 0.0, t >= 0.0], [0, 1])


def OndaCuadrada(amplitud, t, fs=1):
    """Función  de Onda Cuadrada

    Args:
        amplitud (int): Amplitud de la segnal
        t (list): Lista de valores de tiempo
        fs (int, optional): Frecuencia.. Defaults to 1.

    Returns:
        list: Lista de valores
    """
    return ((sp.square(2 * fs*t)) * (amplitud / 2.0)) + (amplitud / 2.0)


def segnal_triangular(amplitud, simetria, t, fs=1):
    """Señal triangular 

    Args:
        amplitud (int): Amplitud de la señal
        simetria (float): simetria de la señal
        t (list): Lista de valores que definen el tiempo.
        fs (int, optional): Frecuencia de la señal. Defaults to 1.

    Returns:
        list: Lista de valores de la señal
    """
    return amplitud*(signal.sawtooth(2 * np.pi * fs * t, simetria))


def seno(amplitud, t, fs=1):
    """ Onda Seno

    Args:
        amplitud (int): Amplitud de la señal
        t (list): Lista de valores de tiempo
        fs (int, optional): Frecuencia de la señal. Defaults to 1.

    Returns:
        list: Lista de valores de la señal de seno
    """
    return amplitud*np.sin(fs*t)


def coseno(amplitud, t, fs=1):
    """Señal de coseno

    Args:
        amplitud (int): Amplitud de la señal
        t (list): lista de valores para generar la señal
        fs (int, optional): Frecuencia de la señal. Defaults to 1.

    Returns:
        list: Lista de valores de la señal
    """
    return amplitud*np.cos(fs*t)


def tiempo(lim_inf, lim_sup, n):
    """Lista de valores que definen el tiempo de la señal

    Args:
        lim_inf (int): Límite inferior del tiempo 
        lim_sup (int): Límite superior del tiempo
        n (int): Cantidad de valores a generar del tiempo

    Returns:
        list: Lista de valores del tiemmpo
    """
    return np.linspace(lim_inf, lim_sup, n)


def plot_signal(xi, xf, yi, yf, t, titulo, etiqueta, values):
    """Generación de la gráfica de la señal.

    Args:
        xi (int): x inicial
        xf (int): x final
        yi (int): y inicial
        yf (int): y final
        t (list): lista de valores de tiempo
        titulo (str): Título de la gráfica
        etiqueta (str): Etiqueta de la señal.
        values (list): Valores de la señal 
    """
    plot(t, values, "k", label=etiqueta, lw=2)
    xlim(xi, xf)


def main():
    st.title("Generación de gráficas de señales")
    st.sidebar.header("Entradas:")
    segnales = ["Escalon Unitario", "Onda Cuadrada",
                "Onda triangular", "Seno", "Coseno"]

    resp = st.sidebar.selectbox("Tipo de señal", segnales)

    st.sidebar.header("Definición del tiempo:")
    st.sidebar.subheader("Rango")
    # SelectBox
    t0 = int(st.sidebar.selectbox(
        "", range(0, 10)
    ))
    ti = 0
    tf = t0
    n = 10000
    t = tiempo(ti, tf, n)
    st.sidebar.subheader("Amplitud de la señal")
    amplitud = int(st.sidebar.selectbox(
        "", range(1, 10)
    ))

    # numpy.ndarray
    if resp == "Escalon Unitario":
        ti = -tf
        resultado = u(amplitud, t)
    elif resp == "Onda Cuadrada":
        st.sidebar.subheader("Frecuencia de la señal")
        fs = int(st.sidebar.selectbox(
            "", range(1, 11)
        ))
        resultado = OndaCuadrada(amplitud, t, fs)
    elif resp == "Onda triangular":
        simetria = 0.5
        st.sidebar.subheader("Frecuencia de la señal")
        fs = int(st.sidebar.selectbox(
            "", range(1, 11)
        ))
        resultado = segnal_triangular(amplitud, simetria, t, fs)
    elif resp == "Seno":
        st.sidebar.subheader("Frecuencia de la señal")
        fs = int(st.sidebar.selectbox(
            "", range(1, 11)
        ))
        resultado = seno(amplitud, t, fs)
    elif resp == "Coseno":
        st.sidebar.subheader("Frecuencia de la señal")
        fs = int(st.sidebar.selectbox(
            "", range(1, 11)
        ))
        resultado = coseno(amplitud, t, fs)
    else:
        resultado = 0
        st.error("Error")

    fig = plt.figure()
    ax = fig.add_subplot(111)
    st.header(f"Gráfica de {resp}")
    ax.plot(t, resultado)
    ax.set_xlim(ti, tf)
    ax.set_xlabel("Tiempo")
    ax.set_ylabel("f(t)")
    ax.set_ylim(2*amplitud*-1, 2*amplitud)
    st.pyplot(fig)

if __name__ == "__main__":
    main()