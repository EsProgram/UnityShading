using System.Collections;
using UnityEngine;

[ExecuteInEditMode]
public class BumpMapShader : MonoBehaviour
{
  [SerializeField]
  private Material bump;

  [SerializeField]
  private Transform lightTransform;

  [SerializeField]
  private float k_diffuse;

  public void Update()
  {
    Vector4 lightPos = lightTransform.position;

    bump.SetVector("light_pos", lightPos);
    bump.SetFloat("k_diffuse", k_diffuse);
  }
}