using System.Collections;
using UnityEngine;

[ExecuteInEditMode]
public class OrenNayar : MonoBehaviour
{
  [SerializeField]
  private Material lambert;

  [SerializeField]
  private Transform lightTransform;

  [SerializeField]
  private float k_diffuse;

  [SerializeField]
  private float k_ambient;
  [SerializeField]
  private float roughness;

  public void Update()
  {
    Vector4 lightPos = lightTransform.position;

    lambert.SetVector("light_pos", lightPos);
    lambert.SetFloat("k_diffuse", k_diffuse);
    lambert.SetFloat("k_ambient", k_ambient);
    lambert.SetFloat("roughness", roughness);
  }
}